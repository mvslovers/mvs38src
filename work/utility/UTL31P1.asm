         TITLE '*** DISASSEMBLY PHASE 1 ***'                            00010028
*                                                                       00020023
* THIS SUB-PROGRAM IS CALLED BY DISASM, AND IS PHASE 2 OF               00030023
* THE DISASSEMBLY PROCESS. A COMMON DATA                                00040023
* AREA IS DEFINED IN DISASM, AND PASSED TO THIS PROGRAM.                00050023
*                                                                       00060023
*    THE SYSIN FILE IS READ TO EXHAUSTION. USING CARDS ARE              00070023
* REFORMATTED AND STORED IN A TABLE - UP TO 256 USING                   00080023
* STATEMENTS MAY BE ENTERED. DSECT CARDS MAY FOLLOW THE                 00090023
* USING STATEMENTS. WHEN USED, DSECT STATEMENTS ARE                     00100023
* REFORMATTED, AND BUILT INTO TABLES. A MAXIMUM OF 256 DSECTS           00110023
* MAY BE ENTERED. DATA ONLY CARDS MAY BE INCLUDED BEFORE, BETWEEN,      00120023
* OR AFTER DSECTS TO SHOW AREAS IN THE PROGRAM WHERE NO INSTRUCTIONS    00130023
* OCCUR. UP TO 256 DATA ONLY AREAS MAY BE SPECIFIED.                    00140023
*                                                                       00150023
*     AT EOF ON SYSIN, A PSEUDO DIS-ASSEMBLY PASS IS MADE               00160023
* USING THE TEXT STORED BY DISASM. ANY RESOLVABLE ADDRESS               00170023
* WITHIN THE TEXT IS USED TO CREATE A NEW ENTRY IN THE                  00180023
* LABEL TABLE, WHICH WILL BE USED BY DISASM2 IN THE                     00190023
* ACTUAL DIS-ASSEMBLY PASS.                                             00200023
*                                                                       00210023
* THE USING CARDS FOR BASE REGISTERS ASSOCIATED WITH DSECT DEFINITIONS  00220023
* MUST BE ENTERED AT SOME POINT AFTER THE DSECT CARDS HAVE BEEN         00230023
* INCLUDED. USING CARDS FOR PROGRAM BASE REGISTERS MAY BE ENTERED       00240023
* AT ANY POINT. THE USING CARD FORMAT IS:                               00250023
*       COL 1-5   : LITERAL 'USING'                                     00260023
*       COL 6     : BLANK                                               00270023
*       COL 7-12  : OFFSET TO BEGIN LOCATION FOR USING RANGE (HEX)      00280023
*       COL 13    : BLANK                                               00290023
*       COL 14-19 : OFFSET TO ENDING LOCATION FOR USING RANGE (HEX)     00300023
*       COL 20    : BLANK                                               00310023
*       COL 21    : BASE RESISTER TO BE USED (HEX, 1-F)                 00320023
*       COL 22    : BLANK                                               00330023
*       COL 23    : TYPE, P=PROGRAM BASE, D=DSECT BASE                  00340023
*       COL 24    : BLANK                                               00350023
*       COL 25-30 : INITIAL BASE REGISTER VALUE IF TYPE P (HEX)         00360023
*       COL 25-32 : DSECT NAME IF TYPE D                                00370023
*                                                                       00380023
*     A DSECT IS ENTERED USING A HEADER CARD,FOLLOWED BY                00390023
* ONE OR MORE FIELD DEFINITION CARDS. ALL FIELD DEFINITION              00400023
* CARDS MUST FOLLOW THE DSECT HEADER CARD. USING CARDS MAY              00410023
* NOT BE INTERSPERSED WITH DSECT DEFINITIONS, BUT MAY PRECEDE           00420023
* OR FOLLOW ANY DSECT.                                                  00430023
*     DSECT HEADER CARD FORMAT:                                         00440023
*        COL 1-8    : DSECT NAME                                        00450023
*        COL 9      : BLANK                                             00460023
*        COL 10-14  : LITERAL 'DSECT'                                   00470023
*        COL 15     : BLANK                                             00480023
*        COL 16-19  : NUMBER OF FIELD CARDS TO FOLLOW (DECIMAL)         00490023
*                                                                       00500023
*     DSECT FIELD CARD FORMAT:                                          00510023
*        COL 1-8    : FIELD NAME                                        00520023
*        COL 9      : BLANK                                             00530023
*        COL 10-13  : OFFSET TO LEFT END OF FIELD (DECIMAL)             00540023
*        COL 14     : BLANK                                             00550023
*        COL 15-17  : LENGTH OF FIELD IN BYTES (DECIMAL)                00560023
*                                                                       00570023
*     A DATA ONLY CARD IS USED TO DESIGNATE A RANGE OF OFFSETS          00580023
* BETWEEN WHICH NO INSTRUCTIONS EXIST. USE OF THESE CARDS ELIMINATES    00590023
* THE CHANCE THAT DATA ELEMENTS WILL BE TREATED AS INSTRUCTIONS         00600023
* BETWEEN THE OFFSETS SPECIFIED. FORMAT IS:                             00610023
*        COL 1-4    : LITERAL 'DATA'                                    00620023
*        COL 5      : BLANK                                             00630023
*        COL 6-11   : OFFSET TO BEGINNING OF AREA (HEX)                 00640023
*        COL 12     : BLANK                                             00650023
*        COL 13-18  : OFFSET TO END OF AREA (HEX)                       00660023
*                                                                       00670023
*                                                                       00680023
*     USER LABEL CARDS ARE USED TO PERMIT SPECIFICATION OF              00690023
* LABELS OTHER THAN THE AXXXXXX NAMES CREATED BY DISASM. THEY           00700023
* MAY APPEAR ANYWHERE IN THE SYSIN STREAM EXCEPT AS THE FIRST           00710023
* CARD, OR WITHIN A DSECT DEFINITION.                                   00720023
*        COL  1-5  : LITERAL 'ULABL'                                    00730023
*        COL   6   : BLANK                                              00740023
*        COL  7-14 : FIELD NAME                                         00750023
*        COL   15  : BLANK                                              00760023
*        COL 16-21 : OFFSET TO LEFT END OF AREA (HEX)                   00770023
*        COL   22  : BLANK                                              00780023
*        COL 23-25 : FIELD LENGTH (DECIMAL)                             00790023
*                                                                       00800023
*      DISASSEMBLY TABLES ARE SET UP IDENTICALLY TO THOSE USED BY       00810023
* DISASM2 FOR THE SIMULATED DISASSEMBLY PERFORMED IN THIS               00820023
* MODULE WHEN ANY PROGRAM BASE REGISTER USING STATEMENTS                00830023
* ARE ENTERED.                                                          00840023
*                                                                       00850023
*     STORAGE IS OBTAINED FOR THE DSECT TABLE AND USING TABLE,          00860023
* AND ADDRESSES OF THESE TABLES ARE STORED IN THE COMMON PARAMETER      00870023
* AREA. USING AND DSECT CARDS ARE EDITED, REFORMATTED, AND PLACED       00880023
* IN THE APPROPRIATE TABLES. IF ANY ERRORS ARE FOUND, THEY ARE          00890023
* PRINTED, AND THE DISASSEMBLY WILL BE TERMINATED ON RETURN             00900023
* TO DISASM.                                                            00910023
*                                                                       00920023
*     STORAGE IS OBTAINED FOR THE LABEL TABLE, AND A SIMULATED          00930023
* DIS-ASSEMBLY IS PERFORMED TO CREATE LABEL TABLE ENTRIES FOR           00940023
* LABELS WHICH WILL BE GENERATED FOR BASE-DISPLACEMENT ADDRESSES        00950023
* BY DISASM2. ON RETURN TO DISASM, THESE LABELS WILL BE SORTED          00960023
* WITH EXTERNAL SYMBOL AND RLD LABELS TO FORM THE FINAL LABEL           00970023
* TABLE TO BE USED BY DISASM2.                                          00980023
*                                                                       00990023
*                                                                       01000023
* AUTHOR R THORNTON - FEB 1978                                          01010023
*                                                                       01020023
*                                                                       01030023
UTL31P1  CSECT ,                       NAME OF PROGRAM                  01040024
*                                                                       01050023
***REGISTER EQUATES***                                                  01060023
*                                                                       01070023
R0       EQU   0                                                        01080023
R1       EQU   1                                                        01090023
R2       EQU   2                                                        01100023
R3       EQU   3                                                        01110023
R4       EQU   4                                                        01120023
R5       EQU   5                                                        01130023
R6       EQU   6                                                        01140023
R7       EQU   7                                                        01150023
R8       EQU   8                                                        01160023
R9       EQU   9                                                        01170023
R10      EQU   10                                                       01180023
R11      EQU   11                                                       01190023
R12      EQU   12                                                       01200023
R13      EQU   13                                                       01210023
R14      EQU   14                                                       01220023
R15      EQU   15                                                       01230023
*                                                                       01240023
*******************  PROGRAM INITIALIZATION  *************************  01250023
*                                                                       01260023
         USING *,R15                                                    01270023
         B     UTL31BGN                                                 01280023
         DROP  R15                                                      01290023
         DC    AL1(L'UTL31ID)                                           01300023
UTL31ID  DC    CL8'UTL31P1'            PROGRAM ID                       01310024
UTL31BGN DS    0H                                                       01320023
         STM   R14,R12,12(R13)         STORE REGS IN HIGH SAVE AREA     01330023
         LR    R3,R15                  INITIALIZE BASE REG              01340023
         LA    R4,4095(,R3)            INITIALIZE THE SECOND            01350023
         LA    R4,1(,R4)               BASE REGISTER                    01360023
         USING UTL31P1,R3,R4                                            01370024
*                                                                       01380023
***GET MAIN STORAGE FOR SAVE AREA***                                    01390023
*                                                                       01400023
         LA    R0,72                   GET 72 BYTES                     01410023
         GETMAIN R,LV=(0)              GET A SAVE AREA                  01420023
*                                                                       01430023
***SET UP SAVE AREA POINTERS***                                         01440023
*                                                                       01450023
         ST    R1,8(,R13)              STORE LOW SAVE POINTER           01460023
         ST    R1,8(,R13)              STORE LOW SAVE POINTER           01470023
         ST    R13,4(,R1)              STORE HIGH SAVE POINTER          01480023
         LR    R13,R1                  INITIALIZE SAVE POINTER          01490023
         L     R1,4(,R13)              GET POINTER TO RESTORE PARA REG  01500023
         L     R1,24(,R1)              RESTORE PARAMETER REGISTER       01510023
*                                                                       01520023
******************************************************************      01530000
*                                                                *      01540000
* CHECK FOR PRIVILEGED AND/OR FLOATING POINT INSTRUCTION OPTION. *      01550000
* IF THESE INSTRUCTIONS ARE NOT TO BE ASSEMBLED, CLEAR THEIR     *      01560000
* INSTRUCTION TABLE ENTRIES.                                     *      01570000
*                                                                *      01580000
******************************************************************      01590000
*                                                                       01600000
         L     R5,0(,R1)               GET PARM FIELD ADDRESS           01610014
         USING COMMPARM,R5                                              01620000
         TM    PRMOPT,FLPTASM          FLOATING POINT INSTR O.K.    DSK 01630006
         BO    TSTPRIV                 YES                          DSK 01640006
         LA    R12,SGLOP               POINT TO OP-CODE TBL             01650000
TSTOPND  DS    0H                                                       01660018
         CLI   0(R12),X'FF'            END OF TBL                       01670018
         BE    TSTPRIV                 YES                              01680000
         TM    ICLASS-INSTENT(R12),FLTPT IS IT FLOATING POINT           01690000
         BZ    FLPSTP                  NO                               01700000
         XC    0(L'SGLOP,R12),0(R12)   CLEAR ENTRY                      01710000
FLPSTP   DS    0H                                                       01720018
         LA    R12,L'SGLOP(,R12)       TO NEXT ENTRY                    01730018
         B     TSTOPND                 LOOP THRU TABLE                  01740000
TSTPRIV  DS    0H                                                       01750018
         TM    PRMOPT,PRIVASM          PRIVILEGED INSTR O.K.        DSK 01760018
         BO    GETUSGTB                YES                          DSK 01770006
         LA    R12,SGLOP               POINT TO OP-CODE TBL             01780000
TTOPND   DS    0H                                                       01790018
         CLI   0(R12),X'FF'            END OF TABLE                     01800018
         BE    CKDBLS                  YES                              01810000
         TM    ICLASS-INSTENT(R12),PRIV PRIVILEGED INSTR                01820000
         BZ    PRIVSTP                 NO                               01830000
         XC    0(L'SGLOP,R12),0(R12)   YES, CLEAR ENTRY                 01840000
PRIVSTP  DS    0H                                                       01850018
         LA    R12,L'SGLOP(,R12)       TO NEXT ENTRY                    01860018
         B     TTOPND                  LOOP THRU TABLE                  01870000
CKDBLS   DS    0H                                                       01880018
         L     R12,DBLOPAD             @ 2-BYTE OP-CODE TBL             01890018
CKDBND   DS    0H                                                       01900018
         CLI   0(R12),X'FF'            END OF TBL                       01910018
         BE    GETUSGTB                YES                              01920000
         TM    ICLASS-INSTENT+2(R12),PRIV PRIVILEGED OP-CODE            01930000
         BZ    DBSTP                   NO                               01940000
         XC    0(L'DBLOP,R12),0(R12)   YES, CLEAR ENTRY                 01950000
DBSTP    DS    0H                                                       01960018
         LA    R12,L'DBLOP(,R12)       TO NEXT ENTRY                    01970018
         B     CKDBND                  LOOP THRU TABLE                  01980000
******************************************************************      01990000
*                                                                *      02000000
* GET STORAGE FOR USING AND DSECT POINTER TABLES.                *      02010000
*                                                                *      02020000
******************************************************************      02030000
GETUSGTB DS    0H                                                       02040018
         GETMAIN R,LV=256*L'USING+48   GET STORAGE FOR USING TABLE      02050018
         MVI   0(R1),X'FF'             SET TABLE END INDIC              02060000
         ST    R1,USGSTRT              SAVE TABLE START ADDR            02070000
         ST    R1,USGCUR               SET TABLE CURRENT ADDR           02080000
         LA    R1,256*L'USING(,R1)     COMPUTE TABLE END ADDR           02090014
         ST    R1,USGEND               SAVE USING TABLE END ADDR        02100000
         L     R2,INDCB                GET SYSIN DCB ADDR               02110000
         LA    R1,EOFCARD              GET EOF ADDR                     02120000
         STCM  R1,7,33(R2)             SET EOF ADDR IN DCB              02130000
         GETMAIN R,LV=256*L'DTB+48     GET STORAGE FOR DSECT TABLE      02140014
         MVI   0(R1),X'FF'             SET TABLE END ADDR               02150000
         ST    R1,DTBSTRT              SAVE DSECT TABLE START ADDR      02160000
         ST    R1,DTBCURR              SAVE DSECT TABLE CURRENT ADDR    02170014
         LA    R1,256*L'DTB(,R11)      COMPUTE TABLE END ADDR           02180014
         ST    R1,DTBEND               SAVE DSECT TABLE END ADDR        02190000
         L     R1,INDCB                @ SYSIN DCB                      02200000
         TM    48(R1),X'10'            IS IT OPEN                       02210000
         BZ    EOFCARD                 NO                               02220000
******************************************************************      02230000
*                                                                *      02240000
* READ SYSIN CARDS, AND DISTRIBUTE TO THE APPROPRIATE PROCESSING *      02250000
* ROUTINE: USINGS, DSECTS, OR DATAS. DETECT ANY ERRORS AND PRINT *      02260000
* ALL CARDS WITH MESSAGES AS NECESSARY.                          *      02270000
*                                                                *      02280000
******************************************************************      02290000
RDCARD   DS    0H                      *** PROCESS SYSIN CARDS ***      02300014
         L     R1,INDCB                GET SYSIN DCB ADDR               02310000
         GET   (1)                     READ NEXT CARD                   02320000
         MVC   WORKREC,0(R1)           MOVE IT TO WORK AREA             02330000
         NOP   MVPRT                   FIRST TIME SWITCH                02340000
         MVI   *-3,C'0'                RESET FIRST TIME SWITCH          02350000
         BAL   R9,PRINT                GO PRINT                     DSK 02360008
         MVC   PRT(30),=C'***** User Entered Cards *****'           DSK 02370029
         BAL   R9,PRINT                GO PRINT                         02380000
         L     R1,4(,R13)              Get previous save area           02390031
         L     R1,20(,R1)              Restore R0 (1st control stmt)    02400031
         MVC   PRT(80),0(R1)           Print first control statement    02410031
         BAL   R9,PRINT                Print it                         02420031
MVPRT    DS    0H                                                       02430018
         MVC   PRT(80),WORKREC         CARD TO PRINT                    02440018
RDGRTN   DS    0H                                                       02450018
         LA    R9,RCCKERR              GET RETURN ADDRESS               02460018
         CLC   WORKREC(5),=C'USING'    IS IT A USING CARD               02470000
         BE    USINGS                  YES                              02480000
         CLC   WORKREC+9(5),=C'DSECT'  IS IT A DSECT HEADER             02490000
         BE    DSECTS                  YES                              02500000
         CLC   WORKREC(4),=C'DATA'     IS IT DATA ONLY CARD             02510000
         BE    DATAS                   YES                              02520000
         CLC   WORKREC(5),=C'ULABL'    IS IT A USER LABEL               02530000
         BE    ULABLS                  YES                              02540000
         MVC   PRT+85(33),=C'Control statement ''     '' invlaid'   DSK 02550029
         MVC   PRT+104(5),WORKREC                                   DSK 02560014
         MVI   USERR,X'FF'             SET ERROR FLAG                   02570000
RCCKERR  DS    0H                                                       02580018
         NI    USERR,X'FE'             RESET CURRENT ERROR FLAG         02590018
         BAL   R9,PRINT                GO PRINT                         02600000
         B     RDCARD                  CONTINUE                         02610000
EOFCARD  DS    0H                                                       02620018
         CLI   USERR,0                 ANY ERRORS FOUND                 02630018
         BNE   EOJ                     YES, EXIT                        02640000
******************************************************************      02650000
*                                                                *      02660000
* CHECK FOR ANY USING CARDS ENTERED. IF NOT, NO PRE-ASSEMBLY IS  *      02670000
* NECESSARY. IF ANY USING CARDS FOUND, CREATE LABEL TABLE ENTRIES*      02680000
* SO THAT USING STATEMENTS WILL BE VALID.                        *      02690000
*                                                                *      02700000
******************************************************************      02710000
         L     R11,USGSTRT             GET USING TBL ADDR               02720000
CUSNGND  DS    0H                                                       02730018
         CLI   0(R11),X'FF'            END OF TABLE                     02740018
         BE    CKPRE                   GO CHECK FOR PRE-DISASM          02750000
         L     R10,CURRLBL             GET LABEL ADDRESS                02760000
         USING USINGD,R11                                               02770000
         USING LABELD,R10                                               02780000
         MVC   LBLADR,USVALU           OFFSET TO LABEL                  02790000
         MVI   LBLTYP,LBLTYPL          LABEL TYPE ENTRY                 02800021
         MVI   LBLLEN,1                SET LENGTH TO 1                  02810000
         MVI   LBLNAME,LBLTYPA         1ST CHAR OF NAME                 02820021
         LA    R12,USVALU              @ OFFSET                         02830000
         BAL   R9,HEXPRT3              CONVERT                          02840000
         MVC   LBLNAME+1(6),PRTABL     MIDDLE OF NAME                   02850000
         MVI   LBLNAME+7,C' '          BLANK LAST POS                   02860000
         LA    R10,L'LABEL(,R10)       STEP TO NEXT LABEL               02870014
         ST    R10,CURRLBL             SAVE IN CURRLBL     FIX******    02880000
         MVC   LBLADR,HIVAL            SET END VALUE       FIX******    02890017
         LA    R11,L'USING(,R11)       STEP TO NEXT USING               02900014
         B     CUSNGND                 LOOP                             02910000
         DROP  R10                                                      02920000
         DROP  R11                                                      02930000
CKPRE    DS    0H                                                       02940018
         L     R1,USGSTRT              GET USING TBL START ADDR         02950018
         CLI   0(R1),X'FF'             ANY ENTRIES                      02960000
         BNE   MAINLINE                YES, GO TO PRE-DISASM            02970000
         B     EOJ                     OTHERWISE GET OUT                02980000
******************************************************************      02990000
*                                                                *      03000000
* EDIT USING CARDS FOR VALIDITY. PUT APPROPRIATE COMMENT IN PRINT*      03010000
* LINE WHEN INVALID. WHEN NO ERRORS FOUND, CREATE AN ENTRY IN THE*      03020000
* USING TABLE.                                                   *      03030000
*                                                                *      03040000
******************************************************************      03050000
USINGS   DS    0H                      *** USING CARD PROCESSING ***    03060014
         L     R12,USGCUR              GET CURRENT USING TBL ADDR       03070000
         C     R12,USGEND              END OF TBL                       03080000
         BNL   UERR6                   YES, TABLE FULL                  03090000
         USING USINGD,R12                                               03100000
         TR    WORKREC+6(6),TRHEX      TRANSLATE TO MAKE HEX            03110000
         TRT   WORKREC+6(6),TRTHEX     CHECK VALID                      03120000
         BNZ   UERR1                   INVALID BEGIN ADDR               03130000
         TR    WORKREC+13(6),TRHEX     TRANSLATE TO MAKE HEX            03140000
         TRT   WORKREC+13(6),TRTHEX    CHECK VALID                      03150000
         BNZ   UERR2                   INVALID END ADDR                 03160000
         TR    WORKREC+20(1),TRHEX     TRANSLATE TO MAKE HEX            03170000
         TRT   WORKREC+20(1),TRTHEX    CHECK VALID                      03180000
         BNZ   UERR3                   INVALID BASE REG                 03190000
         CLI   WORKREC+20,0            VALID BASE REG                   03200000
         BE    UERR3                   NO                               03210000
         CLI   WORKREC+22,C'P'         VALID TYPE                       03220000
         BE    CKINIT                  YES, PROGRAM BASE                03230000
         CLI   WORKREC+22,C'D'         VALID TYPE                       03240000
         BNE   UERR8                   NO, ERROR                        03250000
         L     R1,DTBSTRT              GET DSECT TABLE STRT             03260000
         USING DTBD,R1                                                  03270014
CKDSEND  DS    0H                                                       03280018
         CLI   DTBNAM,X'FF'            END OF TABLE                     03290018
         BE    UERR5                   YES, MISSING DSECT               03300000
         CLC   DTBNAM,WORKREC+24       THIS THE DSECT ENTRY             03310014
         BE    USDSMV                  YES                              03320000
         LA    R1,L'DTB(,R1)           TO NEXT ENTRY                    03330014
         B     CKDSEND                 LOOP THRU DSECT TABLE            03340000
USDSMV   DS    0H                                                       03350018
         MVC   USVALU,DTBFLD@          MOVE DSECT TBL ADDR              03360018
         DROP  R1                                                       03370014
         B     USFINI                  CONTINUE                         03380000
CKINIT   DS    0H                                                       03390018
         TR    WORKREC+24(6),TRHEX     TRANSLATE TO MAKE HEX            03400018
         TRT   WORKREC+24(6),TRTHEX    CHECK VALIDITY                   03410000
         BNZ   UERR4                   INVALID BASE REG VALUE           03420000
         PACK  DBLWD(4),WORKREC+24(7)  PACK TO MAKE HEX                 03430000
         MVC   USVALU,DBLWD            BASE REG VALUE TO USING TBL      03440000
USFINI   DS    0H                                                       03450018
         PACK  DBLWD(4),WORKREC+6(7)   PACK TO MAKE HEX                 03460018
         MVC   USBGN,DBLWD             BEGIN ADDR TO USING TABLE        03470000
         PACK  DBLWD(4),WORKREC+13(7)  PACK TO MAKE HEX                 03480000
         MVC   USEND,DBLWD             END ADDR TO USING TABLE          03490000
         TM    USEND+2,1               IS IT ODD                        03500000
         BO    UERR2                   YES, ERROR                       03510000
         CLI   WORKREC+22,C'D'         DSECT BASE                       03520000
         BE    USFREG                  YES                              03530000
         CLC   USEND,LENGTH+1          WITHIN PROGRAM                   03540000
         BH    UERR2                   YES, ERROR                       03550000
USFREG   DS    0H                                                       03560018
         MVC   USREG,WORKREC+20        BASE REG TO USING TABLE          03570018
         MVC   USTYPE,WORKREC+22       TYPE TO USING TABLE              03580000
         CLC   USBGN,USEND             END < BEGIN                      03590000
         BH    UERR7                   YES, ERROR                       03600000
         LA    R12,L'USING(,R12)       TO NEXT USING TBL ENTRY          03610014
         MVI   0(R12),X'FF'            SET TABLE END INDIC              03620000
         ST    R12,USGCUR              SAVE UPDATED TABLE ADDR          03630000
         BR    R9                      EXIT                             03640000
UERR1    DS    0H                                                       03650018
         MVC   PRT+85(22),=C'Invalid begin col 7-12'                    03660029
         B     UERRS                   CONTINUE                         03670000
UERR2    DS    0H                                                       03680018
         MVC   PRT+85(21),=C'Invalid end col 14-19'                     03690029
         B     UERRS                   CONTINUE                         03700000
UERR3    DS    0H                                                       03710018
         MVC   PRT+85(18),=C'Invalid reg col 21'                        03720029
         B     UERRS                   CONTINUE                         03730000
UERR4    DS    0H                                                       03740018
         MVC   PRT+85(25),=C'Invalid address col 25-30'                 03750029
         B     UERRS                   CONTINUE                         03760000
UERR5    DS    0H                                                       03770018
         MVC   PRT+85(25),=C'Undefined DSECT col 25-32'                 03780029
         B     UERRS                   CONTINUE                         03790000
UERR6    DS    0H                                                       03800018
         MVC   PRT+85(20),=C'Over 256 USING cards'                      03810029
         B     UERRS                   CONTINUE                         03820000
UERR7    DS    0H                                                       03830018
         MVC   PRT+85(16),=C'End before begin'                          03840029
         B     UERRS                   CONTINUE                         03850000
UERR8    DS    0H                                                       03860018
         MVC   PRT+85(19),=C'Invalid type col 23'                       03870029
UERRS    DS    0H                                                       03880018
         MVI   USBGN,X'FF'             INSURE TABLE END INDIC           03890018
         MVI   USERR,X'FF'             SHOW ERROR                       03900000
         BR    R9                      EXIT                             03910000
         DROP  R12                                                      03920000
******************************************************************      03930000
*                                                                *      03940000
* EDIT ULABL CARDS FOR VALIDITY. PUT APPROPRIATE COMMENT IN PRINT*      03950000
* LINE WHEN INVALID. WHEN NO ERRORS FOUND, CREATE AN ENTRY IN THE*      03960000
* LABEL TABLE. SEARCH FOR ANY TYPE A (ADCON) ENTRIES HAVING A    *      03970000
* SYMBOL OF AXXXXXX, WHERE XXXXXX IS THE HEX OFFSET TO THE USER  *      03980000
* LABEL. IF AN A TYPE ENTRY IS FOUND, CHANGE ITS SYMBOLIC NAME TO*      03990000
* THAT OF THE USER LABEL.                                        *      04000000
*                                                                *      04010000
******************************************************************      04020000
ULABLS   DS    0H                      PROCESS USER LABEL CARDS         04030014
         STM   R6,R12,ULSAV            SAVE REGS                        04040000
         CLI   WORKREC+6,C' '          NAME VALID                       04050000
         BE    ULERR1                  NO, 1ST CHAR CANNOT BE BLANK     04060000
         MVC   UNAME+1(6),WORKREC+15   BUILD AXXXXXX NAME               04070000
         TR    WORKREC+15(6),TRHEX     TRANSLATE TO MAKE HEX            04080000
         TRT   WORKREC+15(6),TRTHEX    CHECK VALID HEX                  04090000
         BNZ   ULERR2                  NOT VALID                        04100000
         MVZ   NUMCK,WORKREC+22        ZONES FOR NUMERIC TEST           04110000
         CLC   NUMCK(3),ZEROS          LENGTH IS NUMERIC                04120000
         BNE   ULERR3                  NO, ERROR                        04130000
         L     R6,CURRLBL              GET CURRENT LABEL TABLE ADDRESS  04140000
         USING LABELD,R6                                                04150000
         C     R6,ENDLBL               END OF TABLE                     04160000
         BNL   ULERR4                  YES, ERROR                       04170000
         MVC   LBLNAME,WORKREC+6       NAME TO LABEL ENTRY              04180000
         MVI   LBLTYP,LBLTYPU          TYPE TO LABEL ENTRY              04190021
         PACK  DBLWD,WORKREC+22(3)     PACK LENGTH                      04200000
         CP    DBLWD,=P'256'           LENGTH > 256                     04210027
         BH    ULERR3                  YES, ERROR                       04220010
         CP    DBLWD,=P'0'             LENGTH ZERO                  DSK 04230027
         BE    ULERR3                  YES, ERROR                   DSK 04240010
         CLI   WORKREC+25,C' '         BLANK AFTER LENGTH           DSK 04250010
         BNE   ULERR3                  NO, ERROR                    DSK 04260010
         CVB   R12,DBLWD               CONVERT TO BINARY                04270000
         STC   R12,LBLLEN              LENGTH TO LABEL ENTRY            04280000
         PACK  DBLWD(4),WORKREC+15(7)  PACK TO MAKE VALID HEX           04290000
         MVC   LBLADR,DBLWD            OFFSET TO LABEL                  04300000
         LA    R7,L'LABEL(,R6)         @ NEXT LABEL ENTRY               04310014
         MVC   0(3,R7),HIVAL           SET END INDIC                    04320000
         ST    R7,CURRLBL              SET NEW TABLE END ADDR           04330000
         LR    R7,R6                   SAVE NEW ENTRY ADDRESS           04340000
         L     R6,LBLTBL               GET 1ST LABEL ENTRY ADDR         04350000
ULBCKND  DS    0H                                                       04360018
         C     R6,CURRLBL              END OF TABLE                     04370018
         BNL   ULXIT                   YES, EXIT                        04380000
         CLI   LBLTYP,LBLTYPA          IS IT ADCON ENTRY                04390021
         BNE   ULBSTEP                 NO                               04400000
         CLC   LBLNAME,UNAME           ADCON SYMBOL AT USER LBL ADDR    04410000
         BNE   ULBSTEP                 NO                               04420000
         MVC   LBLNAME,LBLNAME-LABEL(R7) SET USER SYMBOL IN ADCON       04430000
ULBSTEP  DS    0H                                                       04440018
         LA    R6,L'LABEL(,R6)         TO NEXT LABEL ENTRY              04450018
         B     ULBCKND                 LOOP THRU LABEL TABLE            04460000
         B     ULXIT                   EXIT                             04470000
ULERR1   DS    0H                                                       04480018
         MVC   PRT+85(21),=C'Invalid name col 7-14'                     04490029
         B     ULERRS                  CONTINUE                         04500000
ULERR2   DS    0H                                                       04510018
         MVC   PRT+85(28),=C'Invalid hex offset col 16-21'              04520029
         B     ULERRS                  CONTINUE                         04530000
ULERR3   DS    0H                                                       04540018
         MVC   PRT+85(32),=C'Invalid decimal length col 23-25'          04550029
         B     ULERRS                  CONTINUE                         04560000
ULERR4   DS    0H                                                       04570018
         MVC   PRT+85(20),=C'Label table overflow'                      04580029
ULERRS   DS    0H                                                       04590018
         MVI   USERR,X'FF'             SET ERROR FLAG                   04600018
ULXIT    DS    0H                                                       04610018
         LM    R6,R12,ULSAV            RESTORE REGS                     04620018
         BR    R9                      EXIT                             04630000
******************************************************************      04640000
*                                                                *      04650000
* EDIT DSECT CARDS FOR VALIDITY. PUT APPROPRIATE COMMENT IN PRINT*      04660000
* LINE WHEN INVALID. WHEN NO ERRORS FOUND, CREATE AN ENTRY IN THE*      04670000
* DSECT HEADER TABLE, GETMAIN AN AREA TO CONTAIN THE FIELD       *      04680000
* DESCRIPTION ENTRIES, READ AND BUILD FIELD ENTRIES FOR ALL FIELD*      04690000
* DESCRIPTION CARDS ENTERED.                                     *      04700000
*                                                                *      04710000
******************************************************************      04720000
DSECTS   DS    0H                      *** DSECT PROCESSING ***         04730014
         ST    R9,DSCT9                SAVE RETURN ADDR                 04740000
         CLI   WORKREC,C' '            NAME IS BLANK                    04750000
         BE    DSERR1                  YES, ERROR                       04760000
         MVZ   NUMCK,WORKREC+15        ZONES FOR CHECK                  04770000
         CLC   NUMCK,ZEROS             IS NBR FIELDS NUMERIC            04780000
         BNE   DSERR2                  NO, ERROR                        04790000
         L     R12,DTBCURR             GET CURRENT DSECT TBL ADDR       04800014
         C     R12,DTBEND              AT END OF TABLE                  04810000
         BNL   DSERR3                  YES, ERROR                       04820000
         USING DTBD,R12                                                 04830014
         MVC   DTBNAM,WORKREC          NAME TO DSECT TABLE              04840014
         PACK  DBLWD,WORKREC+15(4)     PACK NBR ENTRIES                 04850000
         CVB   R10,DBLWD               CONVERT TO BINARY                04860000
         LA    R10,4(,R10)             ADD FOR SAFETY                   04870014
         MH    R10,DTBLEN              TIMES ENTRY LENGTH               04880000
         GETMAIN R,LV=(10)             GET STORAGE FOR FIELD TABLE      04890000
         STCM  R1,7,DTBFLD@            SAVE FIELD TABLE ADDRESS         04900014
         LA    R12,L'DTBD(,R12)        TO NEXT DSECT TABLE ENTRY        04910014
         ST    R12,DTBCURR             UPDATE CURRENT DSECT TBL ADDR    04920014
         MVI   DTBNAM,X'FF'            SET END INDIC                    04930014
         DROP  R12                                                      04940014
         LR    R12,R1                  COPY FIELD TABLE ADDR            04950000
         BAL   R9,PRINT                PRINT DSECT RECORD               04960000
         USING DSECTD,R12                                               04970000
         CVB   R11,DBLWD               NBR ENTRIES IN LOOP REG          04980000
RDFLD    DS    0H                                                       04990018
         L     R1,INDCB                GET SYSIN DCB ADDR               05000018
         GET   (1)                     READ NEXT CARD                   05010000
         MVC   WORKREC,0(R1)           MOVE RECORD TO WORK AREA         05020000
         MVC   PRT(80),WORKREC         MOVE RECORD TO PRINT AREA        05030000
         CLI   WORKREC,C' '            NAME FIELD BLANK                 05040000
         BE    DSERR1                  YES, ERROR                       05050000
         MVC   DSNAME,WORKREC          NAME TO ENTRY                    05060000
         MVI   DSLBTYP,LBLTYPL         SET LABEL TYPE                   05070022
         MVZ   NUMCK,WORKREC+9         ZONES FOR TEST                   05080000
         CLC   NUMCK,ZEROS             IS OFFSET NUMERIC                05090000
         BNE   DSERR3                  NO, ERROR                        05100000
         PACK  DBLWD,WORKREC+9(4)      PACK OFFSET                      05110000
         CP    DBLWD,=P'4096'          OFFSET > 4096                    05120027
         BH    DSERR3                  YES, ERROR                       05130000
         CVB   R1,DBLWD                CONVERT                          05140000
         STCM  R1,7,DSOFSET            OFFSET TO TABLE ENTRY            05150000
         MVZ   NUMCK(3),WORKREC+14     ZONES FOR TEST                   05160000
         CLC   NUMCK(3),ZEROS          IS LENGTH NUMERIC                05170000
         BNE   DSERR4                  NO, ERROR                        05180000
         PACK  DBLWD,WORKREC+14(3)     PACK LENGTH                      05190000
         CP    DBLWD,=P'256'           LENGTH OVER 256                  05200027
         BH    DSERR4                  YES, ERROR                       05210000
         CVB   R1,DBLWD                CONVERT                          05220000
         LTR   R1,R1                   LENGTH IS ZERO                   05230000
         BZ    DSERR4                  YES, ERROR                       05240000
         STC   R1,DSLENG               LENGTH TO TABLE ENTRY            05250000
         LA    R12,L'DSECT(,R12)       TO NEXT ENTRY                    05260014
         MVI   0(R12),X'FF'            SET TBL END INDIC                05270000
         BAL   R9,PRINT                GO PRINT CARD                    05280000
         BCT   R11,RDFLD               LOOP THRU DSECT                  05290000
         MVC   DSOFSET,HIVAL           TABLE STOPPER                    05300000
         L     R9,DSCT9                GET RETURN ADDR                  05310000
         BR    R9                      EXIT                             05320000
DSERR1   DS    0H                                                       05330018
         MVC   PRT+85(20),=C'Invalid name col 1-8'                      05340029
         B     DSERRS                  CONTINUE                         05350000
DSERR2   DS    0H                                                       05360018
         MVC   PRT+85(31),=C'Invalid number fields col 16-19'           05370029
         B     DSERRS                  CONTINUE                         05380000
DSERR3   DS    0H                                                       05390018
         MVC   PRT+85(24),=C'Invalid offset col 10-13'                  05400029
         B     DSERRS                  CONTINUE                         05410000
DSERR4   DS    0H                                                       05420018
         MVC   PRT+85(24),=C'Invalid length col 15-18'                  05430029
         B     DSERRS                  CONTINUE                         05440000
DSERRS   DS    0H                                                       05450018
         MVI   USERR,X'FF'             SHOW ERROR FOUND                 05460018
         L     R9,DSCT9                GET RETURN ADDR                  05470000
         BR    R9                      EXIT                             05480000
         DROP  R12                                                      05490000
******************************************************************      05500000
*                                                                *      05510000
* EDIT DATA ONLY CARDS FOR VALIDITY. PLACE ERROR DESCRIPTION IN  *      05520000
* PRINT LINE IF ERRORS FOUND. CREATE DATA ONLY TABLE ENTRY IF NO *      05530000
* ERRORS ARE FOUND.                                              *      05540000
*                                                                *      05550000
******************************************************************      05560000
DATAS    DS    0H                      *** DATA CARD PROCESSING ***     05570014
         LA    R0,WORKREC+L'WORKREC-10 END OF RECORD                DSK 05580008
         LA    R1,WORKREC+5            FIRST OFFSET START           DSK 05590008
         SR    R15,R15                 HEX VALUE START AT ZERO      DSK 05600008
DATAS1A  DS    0H                                                   DSK 05610008
         IC    R14,0(,R1)              GET HEX DIGIT                DSK 05620008
         N     R14,=X'0000000F'        REMOVE ALL BUT NUMERIC       DSK 05630008
         CLI   0(R1),C'A'              HEX DIGIT                    DSK 05640008
         BL    DERR1                   NO                           DSK 05650008
         CLI   0(R1),C'F'              HEX DIGIT                    DSK 05660008
         BNH   DATAS1B                 YES                          DSK 05670008
         CLI   0(R1),C'0'              HEX DIGIT                    DSK 05680008
         BL    DERR1                   NO                           DSK 05690008
         CLI   0(R1),C'9'              HEX DIGIT                    DSK 05700008
         BH    DERR1                   NO                           DSK 05710008
         B     DATAS1C                 HANDLE NUMBER                DSK 05720008
DATAS1B  DS    0H                                                   DSK 05730008
         LA    R14,9(,R14)             HANDLE A-F                   DSK 05740008
DATAS1C  DS    0H                                                   DSK 05750008
         SLL   R15,4                   SHIFT PREVIOUS VALUE         DSK 05760008
         AR    R15,R14                 ADD IN HIS HEX DIGIT         DSK 05770008
         LA    R1,1(,R1)               NEXT OFFSET                  DSK 05780008
         CR    R1,R0                   BEYOND END OF INPUT          DSK 05790008
         BH    DERR1                   YES                          DSK 05800008
         CLI   0(R1),C' '              END OF OFFSET                DSK 05810008
         BNE   DATAS1A                 NO                           DSK 05820008
         CL    R15,=X'00FFFFFF'        BEYOND MAX VALUE             DSK 05830008
         BH    DERR1A                  YES                          DSK 05840008
         STCM  R15,7,DBLWD             SAVE FIRST OFFSET            DSK 05850008
         LA    R1,1(,R1)               PAST BLANK                   DSK 05860008
         CR    R1,R0                   BEYOND END OF INPUT          DSK 05870008
         BH    DERR2                   YES                          DSK 05880008
         SR    R15,R15                 HEX VALUE START AT ZERO      DSK 05890008
DATAS2A  DS    0H                                                   DSK 05900008
         IC    R14,0(,R1)              GET HEX DIGIT                DSK 05910008
         N     R14,=X'0000000F'        REMOVE ALL BUT NUMERIC       DSK 05920008
         CLI   0(R1),C'A'              HEX DIGIT                    DSK 05930008
         BL    DERR2                   NO                           DSK 05940008
         CLI   0(R1),C'F'              HEX DIGIT                    DSK 05950008
         BNH   DATAS2B                 YES                          DSK 05960008
         CLI   0(R1),C'0'              HEX DIGIT                    DSK 05970008
         BL    DERR2                   NO                           DSK 05980008
         CLI   0(R1),C'9'              HEX DIGIT                    DSK 05990008
         BH    DERR2                   NO                           DSK 06000008
         B     DATAS2C                 HANDLE NUMBER                DSK 06010008
DATAS2B  DS    0H                                                   DSK 06020008
         LA    R14,9(,R14)             HANDLE A-F                   DSK 06030008
DATAS2C  DS    0H                                                   DSK 06040008
         SLL   R15,4                   SHIFT PREVIOUS VALUE         DSK 06050008
         AR    R15,R14                 ADD IN HIS HEX DIGIT         DSK 06060008
         LA    R1,1(,R1)               NEXT OFFSET                  DSK 06070008
         CR    R1,R0                   BEYOND END OF INPUT          DSK 06080008
         BH    DERR2                   YES                          DSK 06090008
         CLI   0(R1),C' '              END OF OFFSET                DSK 06100008
         BNE   DATAS2A                 NO                           DSK 06110008
         CL    R15,=X'00FFFFFF'        BEYOND MAX VALUE             DSK 06120008
         BH    DERR2A                  YES                          DSK 06130008
         STCM  R15,7,DBLWD+3           SAVE SECOND OFFSET           DSK 06140008
         CLC   DBLWD(3),DBLWD+3        CHECK 1ST LOW                DSK 06150015
         BH    DERR3                   1ST GREATER THAN 2ND ERROR   DSK 06160016
         L     R1,DATOCUR              GET TBL ADDR                     06170000
         USING DTA,R1                                               DSK 06180015
         MVC   DTABGN,DBLWD            MOVE 1ST OFFSET TO TBL       DSK 06190015
         MVC   DTAEND,DBLWD+3          MOVE 2ND OFFSET TO TBL       DSK 06200015
         LA    R1,L'DTA(,R1)           TO NEXT ENTRY                DSK 06210015
         C     R1,DATOEND              TABLE OVERFLOW               DSK 06220015
         BNL   DERR4                   YES, ERROR                   DSK 06230015
         MVC   DTABGN,HIVAL            MARK END OF TABLE            DSK 06240015
         ST    R1,DATOCUR              SAVE CURRENT ENTRY ADDR          06250000
         DROP  R1                                                   DSK 06260015
         BR    R9                      EXIT                             06270000
DERR1    DS    0H                                                       06280018
         MVC   PRT+85(22),=C'1ST offset invalid hex'                    06290029
         B     DERRX                   CONTINUE                     DSK 06300008
DERR1A   DS    0H                                                       06310018
         MVC   PRT+85(18),=C'1ST offset invalid'                    DSK 06320029
         B     DERRS                   CONTINUE                     DSK 06330008
DERR2    DS    0H                                                       06340018
         MVC   PRT+85(22),=C'2ND offset invalid hex'                    06350029
DERRX    DS    0H                                                       06360018
         MVI   PRT+107,C'-'                                         DSK 06370008
         MVC   PRT+108(5),0(R1)                                     DSK 06380008
         B     DERRS                   CONTINUE                         06390000
DERR2A   DS    0H                                                       06400018
         MVC   PRT+85(18),=C'2ND offset invalid'                    DSK 06410029
         B     DERRS                   CONTINUE                     DSK 06420008
DERR3    DS    0H                                                       06430018
         MVC   PRT+85(23),=C'END offset before begin'                   06440029
         B     DERRS                   CONTINUE                     DSK 06450015
DERR4    DS    0H                                                       06460018
         MVC   PRT+85(19),=C'Data table overflow'                   DSK 06470029
DERRS    DS    0H                                                       06480018
         MVI   USERR,X'FF'             FLAG ERROR                       06490018
         BR    R9                      EXIT                             06500000
******************************************************************      06510000
*                                                                *      06520000
* MAINLINE ROUTINE FOR THE PRE-DISASSEMBLY. PURPOSE OF THIS PART *      06530000
* OF THE PROGRAM IS TO ATTEMPT TO CREATE A LABEL ENTRY FOR INSTR-*      06540000
* UCTIONS HAVING STORAGE OPERANDS. THE RESULTING LABEL TABLE WILL*      06550000
* BE SORTED, AND DUPLICATE ENTRIES ELIMINATED BEFORE EXIT FROM   *      06560000
* THIS PHASE OF DISASSEMBLY.                                     *      06570000
*                                                                *      06580000
******************************************************************      06590000
MAINLINE DS    0H                      MAINLINE ROUTINE                 06600014
         L     R6,LBLTBL               @ LABEL TABLE                    06610000
         USING LABELD,R6                                                06620000
         MVC   TXTCURR,TXTSTRT         COPY TEXT START ADDR             06630000
GETCURR  DS    0H                                                       06640018
         L     R7,TXTCURR              @ CURRENT TXT BYTE               06650018
         C     R7,TXTEND               END OF TEXT                      06660000
         BNL   EOJ                     YES             FIX********      06670000
         LR    R12,R7                  COPY TEXT ADDR                   06680000
         S     R12,TXTSTRT             COMPUTE OFFSET                   06690000
         ST    R12,TXTOFST             SAVE OFFSET TO THIS BYTE         06700000
         CLC   NEXCHG,TXTOFSET         TIME TO CHANGE USING TBLS        06710000
         BH    CKDARNG                 NO                               06720000
         BAL   R9,NEXUSG               YES, GO DO IT                    06730000
CKDARNG  DS    0H                                                   DSK 06740015
         L     R12,DATONLY             GET DATA ONLY ENTRY ADDRESS  DSK 06750015
         USING DTA,R12                                              DSK 06760015
CKDTA    DS    0H                                                   DSK 06770015
         C     R12,DATOCUR             LAST ENTRY                   DSK 06780015
         BNL   CKLOSEQ                 END OF TABLE                 DSK 06790015
         CLC   TXTOFSET,DTABGN         RANGE BEGINS LATER           DSK 06800015
         BL    CKDTANX                 YES, CHECK NEXT              DSK 06810015
         CLC   TXTOFSET,DTAEND         THIS BYTE IN THE RANGE       DSK 06820015
         BNH   CONST                   YES, TREAT AS CONSTANT       DSK 06830015
CKDTANX  DS    0H                                                   DSK 06840015
         LA    R12,L'DTA(,R12)         PAST THIS ONE, STEP TO NEXT  DSK 06850015
         B     CKDTA                   AND CHECK AGAIN              DSK 06860015
         DROP  R12                                                  DSK 06870015
CKLOSEQ  DS    0H                                                       06880018
         CLC   TXTOFSET,LBLADR         LABEL ENTRY OUT OF SEQ           06890018
         BNH   GCKODD                  NO, CONTINUE                     06900000
         BAL   R9,FORCONST             YES, FORCE ANY CONSTANT OUT      06910000
         LA    R6,L'LABEL(,R6)         TO NEXT LABEL                    06920014
         B     CKLOSEQ                 CONTINUE SEQ CHK                 06930000
GCKODD   DS    0H                                                       06940018
         TM    TXTCURR+3,1             ODD ADDRESS                      06950018
         BO    CONST                   YES, NOT INSTR                   06960000
         CLC   1(3,R7),0(R7)           4 CONSEC IDENTICAL BYTES         06970000
         BE    CONST                   YES, NOT INSTR                   06980000
         TRT   0(1,R7),CHARTRAN        TEST TEXT BYTE                   06990000
         BNZ   CKINSTR                 NOT CHARACTER                    07000000
         CLI   CONPROG,1               IS CONSTANT IN PROGRESS          07010000
         BNE   CK6                     NO                               07020000
         CLI   CONTYPE,C'C'            IS IT CHARACTER TYPE             07030000
         BE    CONST                   YES, ADD THIS TO CONSTANT        07040000
CK6      DS    0H                                                       07050018
         TRT   0(6,R7),CHARTRAN        6 CONSECUTIVE CHARACTERS         07060018
         BZ    CONST                   YES, NOT INSTRUCTION             07070013
CKINSTR  DS    0H                                                       07080018
         SR    R8,R8                   CLEAR WORK                       07090018
         IC    R8,0(,R7)               PICK UP TXT BYTE                 07100014
         MH    R8,SGOPLEN              TIMES TABLE LENGTH               07110000
         LA    R8,SGLOP(R8)            @ INSTR TBL ENTRY                07120000
         MVC   INSTENT,0(R8)           SAVE INSTRUCTION TBL ENTRY       07130000
         CLI   INAME,0                 IS IT AN INSTR OP-CODE           07140000
         BE    CONST                   NO                               07150000
         CLI   ITYPE,TWO               TWO-BYTE OP-CODE                 07160000
         BNE   INSTR                   NO                               07170000
         L     R8,DBLOPAD              YES, GET 2-BYTE TBL ADDR         07180000
DBLND    DS    0H                                                       07190018
         CLI   0(R8),X'FF'             END OF TABLE                     07200018
         BE    CONST                   YES, NOT INSTR                   07210000
         CLC   0(2,R8),0(R7)           THIS ENTRY MATCHES TXT           07220000
         BE    GOTDBLI                 YES                              07230000
         LA    R8,L'DBLOP(,R8)         TO NEXT ENTRY                    07240014
         B     DBLND                   LOOP THRU TBL                    07250000
GOTDBLI  DS    0H                                                       07260018
         LA    R8,2(,R8)               PASS OP-CODE BYTES               07270018
******************************************************************      07280000
*                                                                *      07290000
* CHECK TO SEE IF THIS BYTE OF THE PROGRAM IS AN INSTRUCTION OP  *      07300000
* CODE. IF SO, PERFORM THE APPROPRIATE PROCESSING ROUTINE.       *      07310000
*                                                                *      07320000
******************************************************************      07330000
INSTR    DS    0H                      *** INSTRUCTIONS (POSSIBLY) ***  07340014
         MVC   ILENG+1(1),INLNG        SET INSTR LENGTH                 07350000
         LH    R12,ILENG               PICK UP LENGTH                   07360000
         AR    R12,R7                  ADDR OF NEXT OP CODE             07370000
         SR    R15,R15                 CLEAR WORK                       07380000
         IC    R15,0(,R12)             PICK UP NEXT OP-CODE             07390014
         MH    R15,SGOPLEN             TIMES TBL ENTRY LENG             07400000
         LA    R15,SGLOP(R15)          INSTR TBL ENTRY ADDR             07410000
         CLI   INAME-INSTENT(R15),0    IS IT AN OP-CODE                 07420000
         BNE   ICKSEC                  YES                              07430000
         CLI   0(R7),X'45'             IS IT BAL                        07440000
         BE    ICKTBL                  YES, CONTINUE                    07450000
         CLI   0(R7),7                 NO, IS IT BRCH                   07460000
         BE    POSSB                   YES                              07470000
         CLI   0(R7),X'47'             IS IT BRCH                       07480000
         BNE   CONST                   NO, THEN THIS NOT INSTR          07490000
POSSB    DS    0H                                                       07500018
         TM    1(R7),X'F0'             IS IT UNCONDL BRCH               07510018
         BNO   CONST                   NO, THEN THIS NOT INSTR          07520000
         B     ICKTBL                  ACCEPT UNCOND BRCHS              07530000
ICKSEC   DS    0H                                                       07540018
         SR    R1,R1                   CLEAR WORK                       07550018
         IC    R1,INLNG-INSTENT(R15)   GET INSTR LENGTH                 07560000
         AR    R1,R12                  ADDR OF NEXT OP CODE             07570000
         SR    R14,R14                 CLEAR WORK                       07580000
         IC    R14,0(,R1)              PICK UP NEXT OP-CODE             07590014
         MH    R14,SGOPLEN             TIMES TBL ENTRY LENG             07600000
         LA    R14,SGLOP(R14)          INSTR TBL ENTRY ADDR             07610000
         CLI   INAME-INSTENT(R14),0    IS IT AN OP-CODE                 07620000
         BNE   ICKTBL                  YES                              07630000
         CLI   0(R12),X'45'            IS IT BAL                        07640000
         BE    ICKTBL                  YES, CONTINUE                    07650000
         CLI   0(R12),X'07'            NO, IS IT BRCH                   07660000
         BE    POSSB2                  YES                              07670000
         CLI   0(R12),X'47'            IS IT BRCH                       07680000
         BNE   CONST                   NO, THEN THIS NOT INSTR          07690000
POSSB2   DS    0H                                                       07700018
         TM    1(R12),X'F0'            IS IT UNCONDL BRCH               07710018
         BNO   CONST                   NO, THEN THIS NOT INSTR          07720000
ICKTBL   DS    0H                                                       07730018
         LH    R12,ILENG               GET INSTR LENGTH                 07740018
         AR    R12,R7                  @ NEXT TEXT LOC                  07750000
         BCTR  R12,R0                  BACK UP 1                        07760000
         S     R12,TXTSTRT             RELATIVIZE IN CSECT              07770000
         CLM   R12,7,LBLADR            LBL TBL ADDR HERE                07780000
         BL    NOILBL                  NO                               07790000
         CLC   TXTOFSET,LBLADR         LABEL AT INSTR START             07800000
         BNE   CONST                   NO, MUST BE CONSTANT             07810000
         CLI   LBLTYP,LBLTYPL          IS IT A LABEL ONLY               07820021
         BNE   CONST                   NO                               07830000
         CLI   CONPROG,1               CONSTANT IN PROGRESS             07840000
         BNE   SETLBL                  NO                               07850000
         BAL   R9,FORCONST             YES, FORCE IT OUT                07860000
SETLBL   DS    0H                                                       07870018
         LA    R6,L'LABEL(,R6)         TO NEXT LABEL TBL ENTRY          07880018
         B     ICKTBL                  GO CHECK NEXT LABEL              07890000
NOILBL   DS    0H                                                       07900018
         CLI   CONPROG,1               CONSTANT IN PROGRESS             07910018
         BNE   MVMNE                   NO                               07920000
         BAL   R9,FORCONST             YES, FORCE IT OUT                07930000
MVMNE    DS    0H                                                       07940018
         MVC   MNEMONIC,0(R8)          SET INSTR MNEMONIC               07950018
         MVC   OFFSET,TXTOFSET         SET OFFSET                       07960000
         MVC   INSTYP,5(R8)            SET INSTR TYPE                   07970000
         MVI   TYPE,X'0D'              SHOW IT IS AN INSTRUCTION        07980000
         MVC   LEN,ILENG+1             SHOW LENGTH                      07990000
         MVC   TEXT(6),0(R7)           MOVE ACTUAL TEXT                 08000000
OPNDFMT  DS    0H                                                       08010018
         TM    ICLASS,FLTPT            FLOATING POINT OP-CODE           08020018
         BO    FPVERFY                 YES, GO VERIFY                   08030000
         CLI   IEDT,0                  ANY EDIT REQUIRED                08040000
         BE    PFMFMT                  NO                               08050000
         B     IVERFY                  YES, GO EDIT                     08060000
PFMFMT   DS    0H                                                       08070018
         SR    R1,R1                   CLEAR WORK                       08080018
         IC    R1,INSTYP               GET INSTRUCTION TYPE             08090000
         L     R9,OPND9                GET FORMAT ROUTINE RETURN ADDR   08100000
         B     *+4(R1)                 TO APPROPRIATE FORMATTING ROUTIN 08110000
         B     INSTOUT                 TYPE=0, RR                       08120000
         B     RXOPND                  TYPE=4, RX                       08130000
         B     SOPND                   TYPE=8, S                        08140000
         B     SIOPND                  TYPE=C, SI                       08150000
         B     RSOPND                  TYPE=10, RS                      08160000
         B     SS1OPND                 TYPE=14, 1-LENGTH SS             08170000
         B     SS2OPND                 TYPE=18, 2-LENGTH SS             08180000
         B     SOPND                   TYPE=1C, 2-BYTE OP-CODES         08190000
         B     RXOPND                  TYPE=20, CONDITIONAL BRANCH      08200000
         B     SVCOPND                 TYPE=24, SVC                     08210000
OPNDRTN  B     INSTOUT                 NORMAL OPERAND FORMAT RETURN     08220000
         B     CONST                   ERROR INSTRUCTION, TREAT AS CONS 08230000
INSTOUT  DS    0H                                                       08240018
         AH    R7,ILENG                STEP TO NEXT TEXT BYTE           08250018
         ST    R7,TXTCURR              SAVE NEXT ADDR                   08260000
         MVC   CCTYPE,ICCSET           SHOW COND CODE SET TYPE          08270000
         B     GETCURR                 CONTINUE TXT PROCESSING          08280000
******************************************************************      08290000
*                                                                *      08300000
* GENERAL OP-CODE TESTS TO VERIFY THAT NON-FLOATING-POINT OP     *      08310000
* CODES ARE INDEED OP-CODES.                                     *      08320000
*                                                                *      08330000
******************************************************************      08340000
IVERFY   DS    0H                      *** VERIFY POSSIBLE INSTRUCTION  08350014
         TM    IEDT,EPR                EVEN-ODD REG PAIR                08360000
         BZ    IVE2                    NO                               08370000
         TM    1(R7),X'10'             R1 IS ODD                        08380000
         BO    CONST                   YES, NOT INSTR                   08390000
         CLI   0(R7),X'0E'             IS IT MVCL                       08400000
         BE    IVTRG2                  YES                              08410000
         CLI   0(R7),X'0F'             IS IT CLCL                       08420000
         BNE   IVE2                    NO                               08430000
IVTRG2   DS    0H                                                       08440018
         TM    1(R7),X'01'             R2 IS ODD                        08450018
         BO    CONST                   YES, NOT INSTR                   08460000
         SR    R1,R1                   CLEAR WORK                       08470000
         SR    R2,R2                   CLEAR WORK                       08480000
         IC    R1,1(,R7)               GET R1R2                         08490014
         SRL   R1,4                    SHIFT OUT R2                     08500000
         PACK  DBLWD(1),1(1,R7)        FLIP R1R2 BYTE                   08510000
         IC    R2,DBLWD                PICK UP R2R1                     08520000
         SRL   R2,4                    SHIFT OUT R1                     08530000
         CR    R1,R2                   R1=R2                            08540000
         BE    CONST                   YES, NOT INSTR                   08550000
         B     PFMFMT                  NO, GOOD INSTR                   08560000
IVE2     DS    0H                                                       08570018
         TM    IEDT,E2                 HALFWORD STORAGE ALIGNMENT       08580018
         BZ    IVE4                    NO                               08590000
         TM    3(R7),X'01'             DISPL IS ODD                     08600000
         BZ    IVES2                   NO, O.K.                         08610000
         TM    2(R7),X'F0'             BASE REG = 0                     08620000
         BNZ   IVES2                   NO, CONTINUE                     08630000
         CLI   0(R7),X'44'             EX OP CODE                       08640000
         BE    CONST                   YES, NOT INSTR                   08650000
         CLI   0(R7),X'47'             BC OP CODE                       08660000
         BE    CONST                   YES, NOT INSTR                   08670000
         CLI   ITYPE,RS                RS INSTRUCTION                   08680000
         BE    CONST                   YES, NOT INSTR                   08690000
         TM    1(R7),X'0F'             INDEX REG IS 0                   08700000
         BZ    CONST                   YES, NOT INSTR                   08710000
         B     IVES2                   CONTINUE                         08720000
IVE4     DS    0H                                                       08730018
         TM    IEDT,E4                 2ND OPND ON FULLWORD BOUND       08740018
         BZ    IVE8                    NO                               08750000
         TM    3(R7),X'03'             DISPL DIV BY 4                   08760000
         BZ    IVES2                   YES, O.K.                        08770000
         TM    2(R7),X'F0'             BASE REG = 0                     08780000
         BNZ   IVES2                   NO, CONTINUE                     08790000
         CLI   ITYPE,RS                RS INSTRUCTION OP CODE           08800000
         BE    CONST                   YES, NOT INSTR                   08810000
         TM    1(R7),X'0F'             INDEX REG = 0                    08820000
         BZ    CONST                   YES, NOT INSTR                   08830000
         B     IVES2                   NO, CONTINUE                     08840000
IVE8     DS    0H                                                       08850018
         TM    IEDT,E8                 2ND OPND ON DBLWD BOUND          08860018
         BZ    IVES2                   NO                               08870000
         TM    3(R7),X'07'             DISPL DIV BY 8                   08880000
         BZ    IVES2                   YES, O.K.                        08890000
         TM    2(R7),X'F0'             BASE REG = 0                     08900000
         BNZ   IVES2                   NO                               08910000
         TM    1(R7),X'0F'             INDEX REG = 0                    08920000
         BZ    CONST                   YES, NOT INSTR                   08930000
IVES2    DS    0H                                                       08940018
         TM    PRMOPT,PRIVASM          PRIVILEGED INSTR O.K.        DSK 08950018
         BO    PFMFMT                  YES                          DSK 08960006
         TM    IEDT,S2                 OPND2 MUST HAVE BASE             08970000
         BZ    IVES1                   NO                               08980000
         TM    2(R7),X'F0'             BASE REG = 0                     08990000
         BNZ   PFMFMT                  NO, O.K.                         09000000
         CLI   ITYPE,RS                RS INSTRUCTION                   09010000
         BE    CONST                   YES, NOT INSTR                   09020000
         CLI   0(R7),X'92'             IS IT MVI OP CODE                09030000
         BE    CONST                   YES, NOT INSTR                   09040000
         TM    1(R7),X'0F'             INDEX REG = 0                    09050000
         BZ    CONST                   YES, NOT INSTR                   09060000
         B     PFMFMT                  NO, GOOD INSTR                   09070000
IVES1    DS    0H                                                       09080018
         TM    IEDT,S1                 1ST OPND MUST HAVE BASE          09090018
         BZ    PFMFMT                  NO, CONTINUE                     09100000
         TM    2(R7),X'F0'             1ST OPND HAS BASE                09110000
         BZ    CONST                   NO, NOT INSTR                    09120000
         B     PFMFMT                  YES, INSTR O.K.                  09130000
******************************************************************      09140000
*                                                                *      09150000
* GENERAL OP-CODE TESTS TO VERIFY THAT FLOATING-POINT OP-CODES   *      09160000
* ARE INDEED OP-CODES.                                           *      09170000
*                                                                *      09180000
******************************************************************      09190000
FPVERFY  DS    0H                      *** VALIDATE FLOATING POINT OP-C 09200014
         TM    1(R7),X'90'             R1 IS 0, 2, 4, OR 6              09210000
         BNZ   CONST                   NO, NOT INSTR                    09220000
         CLI   0(R7),X'27'             MXDR OP-CODE                     09230000
         BE    FPR1EXT                 YES                              09240000
         CLI   0(R7),X'67'             MXD OP-CODE                      09250000
         BNE   FPCKTYP                 NO                               09260000
FPR1EXT  DS    0H                                                       09270018
         TM    1(R7),X'B0'             R1 IS 0 OR 4                     09280018
         BNZ   CONST                   NO, NOT INSTR                    09290000
FPCKTYP  DS    0H                                                       09300018
         CLI   ITYPE,RR                RR TYPE INSTRUCTION              09310018
         BNE   FPRXVER                 NO                               09320000
         TM    1(R7),X'09'             R2 IS 0, 2, 4, 6                 09330000
         BNZ   CONST                   NO, NOT INSTR                    09340000
         CLI   0(R7),X'25'             LRDR OP CODE                     09350000
         BE    FPR2EXT                 YES                              09360000
         CLI   0(R7),X'37'             SXR OP-CODE                      09370000
         BE    FPR2EXT                 YES                              09380000
         CLI   0(R7),X'26'             MXR OP-CODE                      09390000
         BE    FPR2EXT                 YES                              09400000
         CLI   0(R7),X'36'             AXR OP-CODE                      09410000
         BNE   PFMFMT                  NO, GOOD INSTR                   09420000
FPR2EXT  DS    0H                                                       09430018
         TM    1(R7),X'0B'             R2 IS 0 OR 4                     09440018
         BZ    PFMFMT                  YES, GOOD INSTR                  09450000
         B     CONST                   NO, NOT INSTR                    09460000
FPRXVER  DS    0H                                                       09470018
         TM    PRMOPT,PRIVASM          PRIVILEGED INSTRUCTIONS O.K. DSK 09480018
         BO    FPALIGN                 YES                          DSK 09490006
         TM    2(R7),X'F0'             ANT BASE REG                     09500000
         BNZ   FPALIGN                 YES                              09510000
         TM    1(R7),X'0F'             ANY INDEX REG                    09520000
         BZ    CONST                   NO, NOT INSTR                    09530000
FPALIGN  DS    0H                                                       09540018
         TM    2(R7),X'F0'             ANY BASE REG                     09550018
         BNZ   PFMFMT                  YES, ACCEPT INSTR                09560000
         TM    1(R7),X'0F'             ANY INDEX REG                    09570000
         BNZ   PFMFMT                  YES, ACCEPT INSTR                09580000
         TM    3(R7),X'03'             DISPL DIV BY 4                   09590000
         BNZ   CONST                   NO, NOT INSTR                    09600000
         TM    ICLASS,FLSHT            SHORT PRECISION                  09610000
         BO    PFMFMT                  YES, ACCEPT INSTRUCTION          09620000
         TM    3(R7),X'07'             DISPL DIV BY 8                   09630000
         BZ    PFMFMT                  YES, ACCEPT INSTR                09640000
         B     CONST                   NO, NOT INSTR                    09650000
******************************************************************      09660000
*                                                                *      09670000
* PROCESS TEXT BYTES DETERMINED TO BE CONSTANT DATA.             *      09680000
*                                                                *      09690000
******************************************************************      09700000
CONST    DS    0H                      *** PROCESS CONSTANTS ***        09710014
         MVC   WORKREC,BLANX           CLEAR WORK RECORD AREA           09720000
         CLI   CONPROG,1               CONSTANT IN PROGRESS             09730000
         BNE   CCNEW                   NO                               09740000
         CLC   TXTOFSET,LBLADR         LABEL ENTRY HAS THIS OFFSET      09750000
         BNE   CGETYP                  NO                               09760000
CSTNEW   DS    0H                                                       09770018
         BAL   R9,FORCONST             FORCE IT OUT                     09780018
         B     CCNEW                   GO START A NEW ONE               09790000
CGETYP   DS    0H                                                       09800018
         TRT   0(1,R7),CHARTRAN        CHECK DATA TYPE OF BYTE          09810018
         BNZ   CHEX                    IT'S HEX                         09820000
         MVI   CCKTYP+1,C'C'           SET TYPE IN COMPARE              09830000
         B     CCKTYP                  GO COMPARE                       09840000
CHEX     DS    0H                                                       09850018
         MVI   CCKTYP+1,C'X'           SET TYPE IN COMPARE              09860018
CCKTYP   DS    0H                                                       09870018
         CLI   CONTYPE,C' '            TYPE IN PROG SAME AS THIS BYTE   09880018
         BNE   CSTNEW                  NO                               09890000
CUPDCON  DS    0H                                                       09900018
         LH    R11,CONLEN              GET CURRENT LENGTH               09910018
         LA    R11,1(,R11)             ADD 1                            09920014
         STH   R11,CONLEN              UPDATE LENGTH                    09930000
         CLI   CONTYPE,C'C'            CHARACTER CONSTANT               09940000
         BE    CCK8                    YES                              09950000
         TM    CONOFST+3,1             OFFSET IS ODD                    09960000
         BO    CCFIN1                  YES                              09970000
         TM    CONOFST+3,2             HALFWORD OFFSET                  09980000
         BZ    CCFWD                   NO                               09990000
         CLI   CONLEN+1,1              HALFWORD, IS LENGTH = 1          10000000
         BE    CCXIT1                  YES                              10010000
         B     CCFIN1                  NO                               10020000
CCFWD    DS    0H                                                       10030018
         CLI   CONLEN+1,4              NO, IS HEX CONST 4 BYTES         10040018
         BL    CCXIT1                  NOT YET                          10050000
CCFIN1   DS    0H                                                       10060018
         BAL   R9,FORCONST             MAX LENG, FORCE IT OUT           10070018
         B     CCXIT1                  FINISH                           10080000
CCK8     DS    0H                                                       10090018
         CLC   CONLEN,=H'8'            CHAR CONSTANT 8 BYTES            10100027
         BNL   CCFIN1                  YES                              10110000
CCXIT1   DS    0H                                                       10120018
         LA    R7,1(,R7)               STEP OVER 1 BYTE IN TEXT         10130018
         ST    R7,TXTCURR              UPDATE TEXT ADDR                 10140000
         B     GETCURR                 CONTINUE TEXT PROCESSING         10150000
CCNEW    DS    0H                                                       10160018
         MVI   CONPROG,1               SHOW CONSTANT IN PROGRESS        10170018
         MVC   CONOFST,TXTOFST         SET OFFSET TO 1ST BYTE           10180000
         MVC   CONLEN,XZROS            CLEAR LENGTH                     10190000
         CLC   TXTOFSET,LBLADR         LABEL AT THIS OFFSET             10200000
         BE    CLBLD                   YES                              10210000
TRTYPE   DS    0H                                                       10220018
         TRT   0(1,R7),CHARTRAN        CHECK DATA TYPE OF BYTE          10230018
         BNZ   CCSHX                   IT'S HEX                         10240000
         MVI   CONTYPE,C'C'            IT'S CHAR, SO INDICATE           10250000
         B     CUPDCON                 GO COMPLETE                      10260000
CCSHX    DS    0H                                                       10270018
         MVI   CONTYPE,C'X'            IT'S HEX, SO INDICATE            10280018
         B     CUPDCON                 GO COMPLETE                      10290000
CLBLD    DS    0H                                                       10300018
         CLI   LBLTYP,LBLTYPL          IS IT A LABEL ONLY               10310021
         BNE   CDATACON                NO                               10320000
         LA    R6,L'LABEL(,R6)         TO NEXT LABEL ENTRY              10330014
         CLC   TXTOFSET,LBLADR         THIS LABEL AT SAME ADDR          10340000
         BNE   TRTYPE                  NO                               10350000
         CLI   LBLTYP,LBLTYPL          THIS ANOTHER LABEL ONLY          10360021
         BNE   CDATACON                NO                               10370000
         LA    R6,L'LABEL(,R6)         TO NEXT LABEL ENTRY              10380014
         B     CCNEW                   GO TO NEXT LABEL                 10390000
CDATACON DS    0H                                                       10400018
         MVC   CONTYPE,LBLTYP          TYPE TO CONSTANT AREA            10410018
         SR    R1,R1                   CLEAR WORK                       10420000
         IC    R1,LBLLEN               PICK UP CONSTNT LENGTH           10430000
         STH   R1,CONLEN               SAVE CONSTANT LENGTH             10440000
         SR    R11,R11                 CLEAR WORK REG                   10450000
         IC    R11,LBLLEN              PICK UP LENGTH                   10460000
         AR    R7,R11                  STEP PAST TEXT                   10470000
         ST    R7,TXTCURR              UPDATE TEXT ADDRESS              10480000
         BAL   R9,FORCONST             FORCE CONSTANT OUT               10490000
         LA    R6,L'LABEL(,R6)         STEP TO NEXT LABEL ENTRY         10500014
         B     GETCURR                 CONTINUE TEXT PROCESS            10510000
         DROP  R6                                                       10520000
******************************************************************      10530000
*                                                                *      10540000
* CLEAR OUT AREAS SET UP FOR CONSTANT DATA.                      *      10550000
*                                                                *      10560000
******************************************************************      10570000
FORCONST DS    0H                      *** FORCE OUT CONSTANT IN PROGRE 10580014
         MVI   CONPROG,0               RESET CONSTANT IN PROGRESS       10590000
         MVI   CONTYPE,0               RESET TYPE                       10600000
         XC    CONLEN,CONLEN           CLEAR LENGTH                     10610000
         MVC   CONOFST,XZROS           CLEAR OFFSET TO CONSTANT         10620000
         BR    R9                      EXIT                             10630000
******************************************************************      10640000
*                                                                *      10650000
* PROCESS RX-FORMAT INSTRUCTIONS. THE BASE-DISPLACEMENT ADDRESS  *      10660000
* WILL BE SENT TO THE BDLADR ROUTINE FOR LABEL CREATION.         *      10670000
*                                                                *      10680000
******************************************************************      10690000
RXOPND   DS    0H                      *** RX FORMAT INSTRUCTIONS ***   10700014
         SR    R11,R11                 CLEAR WORK REG                   10710000
         ICM   R11,3,TEXT+2            GET BDDD                         10720000
         LA    R10,4                   SET LENGTH = 4                   10730000
         TM    INLNG,E4                FULLWORD OPERAND                 10740000
         BO    RXBDDD                  YES                              10750000
         LA    R10,2                   SET LENGTH = 2                   10760000
         TM    INLNG,E2                HALFWORD OPERAND                 10770000
         BO    RXBDDD                  YES                              10780000
         LA    R10,1                   SET LENGTH = 1                   10790000
         TM    INLNG,E8                DOUBLEWORD OPERAND               10800000
         BZ    RXBDDD                  NO                               10810000
         LA    R10,8                   YES, SET LENGTH = 8              10820000
RXBDDD   DS    0H                                                       10830018
         B     BDLADR                  CHECK LABEL                      10840018
******************************************************************      10850000
*                                                                *      10860000
* PROCESS S-FORMAT INSTRUCTIONS. THE BASE-DISPLACEMENT ADDRESS   *      10870000
* WILL BE SENT TO THE BDLADR ROUTINE FOR LABEL CREATION.         *      10880000
*                                                                *      10890000
******************************************************************      10900000
SOPND    DS    0H                      *** S FORMAT INSTRUCTIONS ***    10910014
         CLI   1(R7),0                 BYTE 2 OF INSTR IS ZERO          10920000
         BE    SCK2                    YES                              10930000
         CLI   0(R7),X'80'             NO, IS IT SSM                    10940000
         BE    4(,R9)                  YES, NOT INSTR                   10950014
         CLI   0(R7),X'82'             NO, IS IT LPSW                   10960000
         BE    4(,R9)                  YES, NOT INSTR                   10970014
         CLI   0(R7),X'93'             NO, IS IT TS                     10980000
         BE    4(,R9)                  YES, NOT INSTR                   10990014
SCK2     DS    0H                                                       11000018
         CLI   0(R7),X'B2'             OP-CODE IS B2                    11010018
         BNE   SSTRT                   NO                               11020000
         CLC   2(2,R7),XZROS           3RD AND 4TH BYTES ZERO           11030000
         BE    SSTRT                   YES                              11040000
         CLI   1(R7),X'0B'             IPK INSTRUCTION                  11050000
         BE    4(,R9)                  YES, NOT INSTR                   11060014
         CLI   1(R7),X'0D'             PTLB INSTR                       11070000
         BE    4(,R9)                  YES, NOT INSTR                   11080014
SSTRT    DS    0H                                                       11090018
         SR    R11,R11                 CLEAR WORK                       11100018
         ICM   R11,3,TEXT+2            GET BDDD                         11110000
         LA    R10,4                   SET LENGTH = 4                   11120000
         TM    INLNG,E4                FULLWORD OPERAND                 11130000
         BO    SBDDD                   YES                              11140000
         LA    R10,2                   SET LENGTH = 2                   11150000
         TM    INLNG,E2                HALFWORD OPERAND                 11160000
         BO    SBDDD                   YES                              11170000
         LA    R10,1                   SET LENGTH = 1                   11180000
         TM    INLNG,E8                DOUBLEWORD OPERAND               11190000
         BZ    SBDDD                   NO                               11200000
         LA    R10,8                   YES, SET LENGTH = 8              11210000
SBDDD    DS    0H                                                       11220018
         B     BDLADR                  CHECK FOR LABEL                  11230018
******************************************************************      11240000
*                                                                *      11250000
* PROCESS SI-FORMAT INSTRUCTIONS. THE BASE-DISPLACEMENT ADDRESS  *      11260000
* WILL BE SENT TO THE BDLADR ROUTINE FOR LABEL CREATION.         *      11270000
*                                                                *      11280000
******************************************************************      11290000
SIOPND   DS    0H                      *** SI FORMAT INSTRUCTIONS ***   11300014
         SR    R11,R11                 CLEAR WORK                       11310000
         ICM   R11,3,TEXT+2            GET BDDD ADDRESS                 11320000
         LA    R10,0                   LENGTH=DON'T CARE                11330000
         B     BDLADR                  CHECK FOR LABEL                  11340000
******************************************************************      11350000
*                                                                *      11360000
* PROCESS RS-FORMAT INSTRUCTIONS. THE BASE-DISPLACEMENT ADDRESS  *      11370000
* WILL BE SENT TO THE BDLADR ROUTINE FOR LABEL CREATION.         *      11380000
*                                                                *      11390000
******************************************************************      11400000
RSOPND   DS    0H                      *** RS FORMAT INSTRUCTIONS ***   11410014
         CLI   0(R7),X'88'             IS IT SHIFT INSTR                11420000
         BL    RSCMA1                  NO                               11430000
         CLI   0(R7),X'8F'             IS IT SHIFT INSTR                11440000
         BH    RSCMA1                  NO                               11450000
         TM    1(R7),X'0F'             SHIFT, IS R3 POS = 0             11460000
         BZ    0(,R9)                  YES, GOOD SHIFT                  11470014
         B     4(,R9)                  NO, NOT INSTR                    11480014
RSCMA1   DS    0H                                                       11490018
         SR    R11,R11                 CLEAR WORK                       11500018
         ICM   R11,3,TEXT+2            GET BDD ADDRESS                  11510000
         LA    R10,4                   SET LENGTH = 4                   11520000
         TM    INLNG,E4                FULLWORD OPERAND                 11530000
         BO    RSBDDD                  YES                              11540000
         LA    R10,2                   SET LENGTH = 2                   11550000
         TM    INLNG,E2                HALFWORD OPERAND                 11560000
         BO    RSBDDD                  YES                              11570000
         LA    R10,1                   SET LENGTH = 1                   11580000
         TM    INLNG,E8                DOUBLEWORD OPERAND               11590000
         BZ    RSBDDD                  NO                               11600000
         LA    R10,8                   YES, SET LENGTH = 8              11610000
RSBDDD   DS    0H                                                       11620018
         B     BDLADR                  CHECK FOR LABEL                  11630018
******************************************************************      11640000
*                                                                *      11650000
* PROCESS SS-FORMAT INSTRUCTIONS. THE BASE-DISPLACEMENT ADDRESSES*      11660000
* WILL BE SENT TO THE BDLADR ROUTINE FOR LABEL CREATION. THE     *      11670000
* SINGLE-LENGTH SS FORMAT INSTRUCTIONS ARE HANDLED HERE.         *      11680000
*                                                                *      11690000
******************************************************************      11700000
SS1OPND  DS    0H                      *** SS FORMAT INSTRUCTIONS - SIN 11710014
         SR    R10,R10                 CLEAR WORK                       11720000
         IC    R10,TEXT+1              GET LENGTH CODE                  11730000
         LA    R10,1(,R10)             COMPUTE ACTUAL LENGTH            11740014
         SR    R11,R11                 CLEAR WORK                       11750000
         ICM   R11,3,TEXT+2            GET BDDD ADDRESS                 11760000
         LA    R1,SS1RTN               GET RTEURN ADDR                  11770000
         MVC   SAVOP9,OPND9            SAVE NORMAL RETURN ADDR          11780000
         ST    R1,OPND9                CHANGE RETURN ADDR               11790000
         B     BDLADR                  CHECK LABEL                      11800000
SS1RTN   DS    0H                                                       11810018
         MVC   OPND9,SAVOP9            RESTORE NORMAL RETURN ADDR       11820018
         SR    R11,R11                 CLEAR WORK                       11830000
         ICM   R11,3,TEXT+4            GET SECOND BDDD ADDRESS          11840000
         SR    R10,R10                 CLEAR LENGTH REG                 11850000
         IC    R10,TEXT+1              GET INSTR LENGTH                 11860000
         LA    R10,1(,R10)             COMPUTE ACTUAL LENGTH            11870014
         B     BDLADR                  CHECK FOR LABEL                  11880000
******************************************************************      11890000
*                                                                *      11900000
* PROCESS SS-FORMAT INSTRUCTIONS. THE BASE-DISPLACEMENT ADDRESSES*      11910000
* WILL BE SENT TO THE BDLADR ROUTINE FOR LABEL CREATION. THE     *      11920000
* DOUBLE-LENGTH SS FORMAT INSTRUCTIONS ARE HANDLED HERE.         *      11930000
*                                                                *      11940000
******************************************************************      11950000
SS2OPND  DS    0H                      *** SS FORMAT INSTRUCTIONS - 2 L 11960014
         SR    R10,R10                 CLEAR WORK                       11970000
         IC    R10,TEXT+1              GET L1L2                         11980000
         SRL   R10,4                   SHIFT OUT L2                     11990000
         LA    R10,1(,R10)             COMPUTE ACTUAL LENGTH            12000014
         SR    R11,R11                 CLEAR WORK                       12010000
         ICM   R11,3,TEXT+2            GET BDDD ADDRESS                 12020000
         LA    R1,SS2RTN               GET RETURN ADDR                  12030000
         MVC   SAVOP9,OPND9            SAVE NORMAL RETURN ADDR          12040000
         ST    R1,OPND9                CHANGE RETURN ADDRESS            12050000
         B     BDLADR                  CHECK LABEL                      12060000
SS2RTN   DS    0H                                                       12070018
         MVC   OPND9,SAVOP9            RESTORE NORMAL RETURN ADDR       12080018
         SR    R11,R11                 CLEAR WORK                       12090000
         ICM   R11,3,TEXT+4            GET 2ND BDDD ADDR                12100000
         PACK  DBLWD(1),TEXT+1(1)      FLIP LENGTH BYTE                 12110000
         SR    R10,R10                 CLEAR WORK                       12120000
         IC    R10,DBLWD               PICK UP L2L1                     12130000
         SRL   R10,4                   SHIFT OUT L1                     12140000
         CLI   TEXT,X'F0'              SRP OP-CODE                      12150000
         BNE   SS2BDDD                 NO                               12160000
         IC    R10,TEXT+1              GET INSTR LENGTH                 12170000
         SRL   R10,4                   SHIFT OUT I3                     12180000
SS2BDDD  DS    0H                                                       12190018
         LA    R10,1(,R10)             COMPUTE ACTUAL LENGTH            12200018
         B     BDLADR                  CHECK LABEL                      12210000
******************************************************************      12220000
*                                                                *      12230000
* PROCESS SVC INSTRUCTIONS. THE SOLE PROCESSING IS TO VERIFY THAT*      12240000
* THIS IS A VALID SVC.                                           *      12250000
*                                                                *      12260000
******************************************************************      12270000
SVCOPND  DS    0H                      *** SVC INSTRUCTIONS ***         12280014
         CLI   TEXT+1,126              VALID OPERAND                    12290000
         BH    NOTSVC                  NO, NOT SVC                      12300000
         L     R1,SVCTBLAD             GET SVC TABLE ADDRESS            12310000
SVCKND   DS    0H                                                       12320018
         CLI   0(R1),X'FF'             END OF SVC TABLE                 12330018
         BE    NOTSVC                  YES, MUST NOT BE SVC             12340000
         CLC   0(1,R1),TEXT+1          THIS THE ENTRY                   12350000
         BE    GOTSVC                  YES                              12360000
         LA    R1,L'SVCOP(,R1)         STEP TO NEXT ENTRY               12370014
         B     SVCKND                  LOOP THRU TABLE                  12380000
NOTSVC   DS    0H                                                       12390018
         B     4(,R9)                  ERROR RETURN                     12400018
GOTSVC   DS    0H                                                       12410018
         BR    R9                      EXIT, NO STORAGE OPND            12420018
******************************************************************      12430000
*                                                                *      12440000
* SET UP CURRENT BASE REGISTERS IN THE BASE TABLE. THE USING     *      12450000
* TABLE IS SCANNED FOR ENTRIES VALID AT THE CURRENT TEXT OFFSET. *      12460000
* WHEN A BASE REGISTER ENTRY IS FOUND TO BE VALID AT THE CURRENT *      12470000
* TEXT OFFSET, THE USING ENTRY IS MOVED TO THE APPROPRIATE LOC-  *      12480000
* ATION IN THE BASE TABLE FOR USE BY THE BDLADR ROUTINE. THE TEXT*      12490000
* OFFSET TO THE NEXT BASE REGISTER CHANGE IS SET SO THAT THIS    *      12500000
* ROUTINE WILL AGAIN BE ENTERED WHEN THE CURRENT BASE REGISTERS  *      12510000
* ARE EXHAUSTED.                                                 *      12520000
*                                                                *      12530000
******************************************************************      12540000
NEXUSG   DS    0H                      *** GET NEXT BASE REGS ***       12550014
         MVI   MORUSG,0                RESET INDICATOR                  12560000
         XC    BASES,BASES             CLEAR OLD BASE REG VALUES        12570000
         MVC   NEXCHG,HIVAL            SET NEXT CHANGE LOC HIGH         12580000
         L     R2,USGSTRT              GET USING TBL START              12590000
         USING USINGD,R2                                                12600000
ENDUS    DS    0H                                                       12610018
         CLI   0(R2),X'FF'             END OF TABLE                     12620018
         BER   R9                      YES, EXIT                        12630014
         CLC   TXTOFSET,USEND          PAST THIS ONE                    12640000
         BNL   ECSTEP                  YES                              12650000
         OI    MORUSG,1                SHOW MORE BASES AVAILABLE        12660000
USBGCK   DS    0H                                                       12670018
         CLC   TXTOFSET,USBGN          THIS STARTS LATER                12680018
         BNL   CKNEWLO                 NO                               12690000
         CLC   USBGN,NEXCHG            BEGINS BEFORE NEXT CHG           12700000
         BNL   ECSTEP                  NO                               12710000
         MVC   NEXCHG,USBGN            YES, SET NEW CHANGE OFFSET       12720000
         B     ECSTEP                  CONTINUE                         12730000
CKNEWLO  DS    0H                                                       12740018
         CLC   USEND,NEXCHG            NEW LOW CHANGE ADDR              12750018
         BNL   ECMVC                   NO                               12760000
         MVC   NEXCHG,USEND            YES, SET LOWER OFFSET            12770000
ECMVC    DS    0H                                                       12780018
         SR    R1,R1                   CLEAR WORK                       12790018
         IC    R1,USREG                PICK UP REGISTER                 12800000
         MH    R1,USGLEN               TIMES ENTRY LENGTH               12810000
         LA    R1,BASES(R1)            @ TABLE ENTRY                    12820000
         MVC   0(L'USING,R1),USING     ENTRY TO TABLE                   12830000
         OI    MORUSG,X'80'            SHOW BASE REG CURRENT            12840000
ECSTEP   DS    0H                                                       12850018
         LA    R2,L'USING(,R2)         TO NEXT USING TBL ENTRY          12860018
         B     ENDUS                   LOOP THRU USING TBL              12870000
         DROP  R2                                                       12880000
******************************************************************      12890000
*                                                                *      12900000
* A BASE-DISPLACEMENT IS PROVIDED IN REG 11 ON ENTRY. IF ANY     *      12910000
* BASE REGISTERS ARE CURRENT, AND THE BASE REGISTER FOR THE GIVEN*      12920000
* ADDRESS IS A CURRENT PROGRAM BASE REGISTER, A LABEL ENTRY IS   *      12930000
* BUILT. OFFSET TO THE LABEL WILL BE FOUND BY ADDING THE ASSUMED *      12940000
* BASE REGISTER VALUE TO THE GIVEN DISPLACEMENT. THE LABEL NAME  *      12950000
* WILL BE THE LETTER 'A' FOLLOWED BY THE OFFSET.                 *      12960000
*                                                                *      12970000
******************************************************************      12980000
BDLADR   DS    0H                      *** BUILD LABEL ENTRIES ***      12990014
         TM    MORUSG,1                ANY BASES CURRENT                13000000
         BZ    BDLXIT                  NO                               13010000
         LR    R2,R11                  COPY BDDD ADDRESS                13020000
         SRL   R2,12                   RIGHT JUSTIFY BASE REG           13030000
         MH    R2,USGLEN               TIMES ENTRY LENGTH               13040000
         LA    R2,BASES(R2)            @ BASE REG TABLE ENTRY           13050000
         USING USINGD,R2                                                13060000
         CLI   USTYPE,C'P'             IS IT A PROGRAM BASE             13070000
         BNE   BDLXIT                  NO                               13080000
         SLL   R11,20                  ISOLATE THE                      13090000
         SRL   R11,20                  DDD IN R11                       13100000
         SR    R1,R1                   CLEAR WORK                       13110000
         ICM   R1,7,USVALU             GET BASE REG VALUE               13120000
         AR    R11,R1                  COMPUTE PROGRAM OFFSET           13130000
         DROP  R2                                                       13140000
         L     R1,CURRLBL              GET LBL TBL ADDR                 13150000
         C     R1,ENDLBL               END OF TABLE                     13160000
         BL    GOTHOLE                 NO                               13170000
         BAL   R9,COMPLBL              YES, COMPRESS DUPLICATES         13180000
         L     R1,CURRLBL              GET NEW CURRENT LBL ADDR         13190000
         C     R1,ENDLBL               STILL AT END                     13200000
         BNL   TXTEND                  YES, TERMINATE THIS STAGE        13210000
         USING LABELD,R1                                                13220000
GOTHOLE  DS    0H                                                       13230018
         STCM  R11,7,LBLADR            SET LABEL ENTRY OFFSET           13240018
         MVI   LBLNAME,C'A'            BEGIN LABEL NAME                 13250000
         LA    R12,LBLADR              @ OFFSET                         13260000
         BAL   R9,HEXPRT3              GO CONVERT                       13270000
         MVC   LBLNAME+1(6),PRTABL     REST OF NAME                     13280000
         MVI   LBLNAME+7,C' '          FINAL BLANK IN NAME              13290000
         MVI   LBLTYP,LBLTYPL          SET LABEL TYPE                   13300021
         CLI   TEXT,X'47'              THIS A CONDITIONAL BRANCH        13310000
         BE    INSTREF                 YES                              13320000
         CLI   TEXT,X'45'              BAL INSTR                        13330000
         BE    INSTREF                 YES                              13340000
         CLI   TEXT,X'46'              BCT INSTR                        13350000
         BE    INSTREF                 YES                              13360000
         CLI   TEXT,X'44'              EX INSTR                         13370000
         BE    INSTREF                 YES                              13380000
         CLI   TEXT,X'87'              BXLE INSTRUCTION                 13390000
         BE    INSTREF                 YES                              13400000
         CLI   TEXT,X'86'              BXH INSTRUCTION                  13410000
         BNE   BDLSTP                  NO                               13420000
INSTREF  DS    0H                                                       13430018
         SR    R12,R12                 CLEAR WORK REG                   13440018
         A     R11,TXTSTRT             BRCH ADDR IN STORED TEXT         13450000
         LA    R10,4                   ASSUME LENGTH IS 4               13460000
         TM    0(R11),X'C0'            TEST HI 2-BITS OF OP-CODE        13470000
         BM    BDLSTP                  01 OR 10 IS 4-BYTE INSTR         13480000
         BO    BDLSIX                  YES, SIX-BYTE INSTR              13490000
         LA    R10,2                   BOTH OFF, 2-BYTE INSTR           13500000
         B     BDLSTP                  CONTINUE                         13510000
BDLSIX   DS    0H                                                       13520018
         LA    R10,6                   SET LENGTH TO 6                  13530018
BDLSTP   DS    0H                                                       13540018
         STC   R10,LBLLEN              LENGTH TO LABEL ENTRY            13550018
         LA    R1,L'LABEL(,R1)         TO NEXT ENTRY                    13560014
         ST    R1,CURRLBL              SAVE UPDATED TBL ADDR            13570000
BDLXIT   DS    0H                                                       13580018
         L     R9,OPND9                GET RETURN ADDR                  13590018
         BR    R9                      EXIT                             13600000
         DROP  R1                                                       13610000
******************************************************************      13620000
*                                                                *      13630000
* SORT THE LABEL TABLE AND ELIMINATE ANY DUPLICATE ENTRIES.      *      13640000
*                                                                *      13650000
******************************************************************      13660000
COMPLBL  DS    0H                      *** COMPRESS AND SORT LABEL TABL 13670014
         USING LABELD,R6                                                13680000
         L     R6,LBLTBL               GET LABEL TABLE ADDR             13690000
LBSTPASS DS    0H                                                       13700018
         LA    R7,L'LABEL(,R6)         @ NEXT LABEL TABLE ENTRY         13710018
LBLND    DS    0H                                                       13720018
         C     R7,CURRLBL              AT TABLE END                     13730018
         BL    LBSAMPS                 NO                               13740000
NEXPAS0  DS    0H                                                       13750018
         LA    R6,L'LABEL(,R6)         TO NEXT LABEL ENTRY              13760018
         C     R6,CURRLBL              END OF TABLE                     13770000
         BL    LBSTPASS                NO                               13780000
         B     LBFEND                  YES, FIND END                    13790000
LBSAMPS  DS    0H                                                       13800018
         CLC   LBLADR,LBLADR-LABEL(R7) IDENTICAL OFFSETS                13810018
         BH    LBSWCH                  NO, FIRST HIGH, SWITCH           13820000
         BL    LBSTP                   NO, LOW, CONTINUE SCAN           13830000
         CLC   LABEL,0(R7)             ENTRIES ARE IDENTICAL            13840000
         BNE   LBCKLBL                 NO                               13850000
LBNULL2  DS    0H                                                       13860018
         MVC   LBLADR-LABEL(3,R7),HIVAL YES, NULL 2ND                   13870018
         B     LBSTP                   AND CONTINUE SCAN                13880000
LBCKLBL  DS    0H                                                       13890018
         CLC   LBLNAME,LBLNAME-LABEL(R7) IDENTICAL LABELS               13900018
         BNE   LBCKTYP                 NO, CHECK TYPES                  13910000
LBCKLN   DS    0H                                                       13920018
         CLI   LBLLEN,0                THIS ENTRY LENGTH = 0            13930018
         BNE   LBCKLN2                 NO                               13940000
         MVI   LBLLEN,X'FF'            YES, SET HIGH LENGTH             13950000
LBCKLN2  DS    0H                                                       13960018
         CLC   LBLLEN,LBLLEN-LABEL(R7) COMPARE LENGTHS                  13970018
         BH    LBSWCH                  1ST LENGTH HIGH, SWITCH ENTRIES  13980000
         B     LBNULL2                 1ST LOW/=, NULL 2ND              13990000
LBCKTYP  DS    0H                                                       14000018
         CLC   LBLTYP,LBLTYP-LABEL(R7) SAME ENTRY TYPE                  14010018
         BNE   LBCK1L                  NO, CHK TYPE ORDER               14020000
         CLI   LBLTYP,LBLTYPL          ARE THEY TYPE L                  14030021
         BE    LBSTP                   YES, CONTINUE SCAN               14040000
         CLI   LBLTYP,LBLTYPU          USER LABEL                       14050021
         BNE   LBNULL2                 NO                               14060000
         B     LBSTP                   YES                              14070000
LBCK1L   DS    0H                                                       14080018
         CLI   LBLTYP,LBLTYPU          1ST IS USER LABEL                14090030
         BNE   LBCK2L                  NO                               14100000
         CLI   LBLTYP-LABEL(R7),LBLTYPL 2ND IS TYPE LABEL               14110021
         BE    LBNULL2                 YES, NULL THE 2ND                14120000
         B     LBSTP                   CONTINUE SCAN                    14130000
LBCK2L   DS    0H                                                       14140018
         CLI   LBLTYP-LABEL(R7),LBLTYPU 2ND IS USER LABEL               14150021
         BE    LBSWCH                  YES                              14160000
         CLI   LBLTYP,LBLTYPL          1ST IS LABEL TYPE                14170021
         BE    LBSTP                   YES, CONTINUE SCAN               14180000
LBSWCH   DS    0H                                                       14190018
         MVC   WORKREC(L'LABEL),LABEL  HOLD 1ST ENTRY                   14200018
         MVC   LABEL,0(R7)             MOVE 2ND ENTRY TO 1ST            14210000
         MVC   0(L'LABEL,R7),WORKREC   1ST ENTRY TO 2ND LOCATION        14220000
         B     LBSAMPS                 GO RECHECK                       14230000
LBSTP    DS    0H                                                       14240018
         LA    R7,L'LABEL(,R7)         TO NEXT LABEL ENTRY              14250018
         B     LBLND                   CONTINUE SCAN                    14260000
LBFEND   DS    0H                                                       14270018
         L     R6,LBLTBL               @ LABEL TABLE                    14280018
LBFCKFF  DS    0H                                                       14290018
         CLI   LABEL,X'FF'             NULL ENTRY                       14300018
         BE    LBSTCURR                YES                              14310000
         C     R6,CURRLBL              AT FORMER END                    14320000
         BE    LBSTCURR                YES                              14330000
         LA    R6,L'LABEL(,R6)         TO NEXT ENTRY                    14340014
         B     LBFCKFF                 LOOP TO FIND END                 14350000
LBSTCURR DS    0H                                                       14360018
         ST    R6,CURRLBL              SAVE NEW TBL END ADDR            14370018
         BR    R9                      EXIT                             14380000
         DROP  R6                                                       14390000
******************************************************************      14400000
*                                                                *      14410000
* END OF PHASE 1. SORT/COMPRESS THE LABEL TABLE AND RETURN.      *      14420000
*                                                                *      14430000
******************************************************************      14440000
EOJ      DS    0H                      END OF JOB                       14450014
         BAL   R9,COMPLBL              SORT/COMPRESS LABEL TBL          14460000
         L     R6,LBLTBL               GET LABEL TABLE ADDR             14470000
         USING LABELD,R6                                                14480000
EOJCKND  DS    0H                                                       14490018
         C     R6,CURRLBL              END OF TABLE                     14500018
         BNL   EOJ2                    YES                              14510000
         CLI   LBLTYP,LBLTYPU          USER LABEL                       14520021
         BNE   EOJSTEP                 NO                               14530000
         MVI   LBLTYP,LBLTYPL          YES, CHANGE TO TYPE LABEL        14540021
EOJSTEP  DS    0H                                                       14550018
         LA    R6,L'LABEL(,R6)         TO NEXT ENTRY                    14560018
         B     EOJCKND                 CONTINUE LOOP                    14570000
         DROP  R6                                                       14580000
EOJ2     DS    0H                                                       14590018
         MVC   PRT,BLANX               CLEAR PRINT                      14600018
         L     R13,4(,R13)             GET POINTER TO CALLER'S SAVE ARE 14610014
         LM    R14,R12,12(R13)         RESTORE CALLER'S REGS            14620000
         SR    R15,R15                 CLEAR RETURN CODE                14630000
         BR    R14                     RETURN TO CALLER                 14640000
******************************************************************      14650000
*                                                                *      14660000
* CONVERT HEX BYTES TO THEIR PRINTABLE EQUIVALENTS. ON ENTRY, REG*      14670000
* 12 CONTAINS THE ADDRESS OF THE FIRST BYTE TO BE CONVERTED. THE *      14680000
* NUMBER OF BYTES IS DETERMINED BY THE ENTRY SELECTED. PRINTABLE *      14690000
* HEX IS PLACED IN THE FIELD PRTABL, TWO CHARACTERS PER BYTE.    *      14700000
*                                                                *      14710000
******************************************************************      14720000
HEXPRT   DS    0H                                                       14730018
         DS    0H                      HEX TO PRINTABLE ROUTINE         14740018
HEXPRT1  DS    0H                                                       14750018
         UNPK  PRTABL(3),0(2,R12)      UNPACK HEX                       14760018
         B     HEXCLTR                 CONTINUE                         14770000
HEXPRT2  DS    0H                                                       14780018
         UNPK  PRTABL(5),0(3,R12)      UNPACK HEX                       14790018
         B     HEXCLTR                 CONTINUE                         14800000
HEXPRT3  DS    0H                                                       14810018
         UNPK  PRTABL(7),0(4,R12)      UNPACK HEX                       14820018
         B     HEXCLTR                 CONTINUE                         14830000
HEXPRT4  DS    0H                                                       14840018
         UNPK  PRTABL(9),0(5,R12)      UNPACK HEX                       14850018
HEXCLTR  DS    0H                                                       14860018
         MVZ   PRTABL(8),XZROS         CLEAR FOR TRANSLATE              14870018
         TR    PRTABL(8),TRTBL         MAKE PRINTABLE                   14880000
         BR    R9                      EXIT                             14890000
******************************************************************      14900000
*                                                                *      14910000
* PRINT A LINE USING THE SYSPRINT DCB DEFINED IN DISASM PHASE 0. *      14920000
*                                                                *      14930000
******************************************************************      14940000
PRINT    DS    0H                      PRINT ROUTINE                    14950014
         L     R1,PRINTDCB             @ SYSPRINT DCB                   14960000
         TM    48(R1),X'10'            IS SYSPRINT OPEN                 14970000
         BNO   CLRPRT                  NO                               14980000
         PUT   (1),PRTLINE             WRITE PRINT LINE                 14990000
CLRPRT   DS    0H                                                       15000018
         MVC   PRT,BLANX               CLEAR PRINT LINE                 15010018
         AP    LINECT,=P'1'            INCR LINE COUNTER                15020027
         CLI   PCC,C' '                SINGLE SPACED                    15030000
         BE    SETSGL                  YES                              15040000
         AP    LINECT,=P'1'            INCR LINE COUNTER                15050027
         CLI   PCC,C'0'                DOUBLE SPACED                    15060000
         BE    SETSGL                  YES                              15070000
         AP    LINECT,=P'1'            INCR LINE COUNTER                15080027
         CLI   PCC,C'-'                TRIPLE SPACED                    15090000
         BE    SETSGL                  YES                              15100000
         ZAP   LINECT,=P'0'            NO, MUST BE NEW PAGE             15110027
SETSGL   DS    0H                                                       15120018
         MVI   PCC,C' '                SET SINGLE SPACING               15130018
         CP    LINECT,=P'58'           PAST END OF PAGE                 15140027
         BH    NEWPAGE                 YES                              15150000
         BR    R9                      EXIT                             15160000
NEWPAGE  DS    0H                                                       15170018
         MVI   PCC,C'1'                SET SKIP TO HOF                  15180018
         ZAP   LINECT,=P'0'            RESET LINE COUNTER               15190027
         BR    R9                      EXIT                             15200000
******************************************************************      15210014
*                                                                *      15220014
*                 *** DATA AND WORK AREAS ***                    *      15230014
*                                                                *      15240014
******************************************************************      15250000
         LTORG ,                                                        15260027
SVCTBLAD DC    A(SVCOP)                @ SVC TABLE                      15270000
DBLOPAD  DC    A(DBLOP)                @ TWO-BYTE OP-CODE TBL           15280000
OPND9    DC    A(OPNDRTN)              RETURN ADDR FOR OPERAND ROUTINES 15290000
DSCT9    DC    F'0'                    RETURN FOR DSECTS                15300014
SAVOP9   DC    F'0'                    SAVE AREA FOR OPND9              15310014
ULSAV    DC    7F'0'                   SAVE AREA FOR CKADCON            15320014
HIVAL    DC    4X'FF'                  CONSTANT F'S                     15330027
SGOPLEN  DC    AL2(L'SGLOP) SINGLE BYTE OP COD TBL LEN                  15340014
DTBLEN   DC    AL2(L'DSECT) DSECT TABLE ENTRY LENGTH                    15350014
NUMCK    DC    C'0000'                 NUMERIC CHECK AREA               15360000
ZEROS    DC    C'0000'                 CONSTANT ZEROS                   15370000
ILENG    DC    H'0'                    INSTRUCTION LENGTH  FIX***       15380000
CONPROG  DC    X'00'                   CONSTANT IN PROGRESS INDIC       15390000
BASES    DC    XL256'0'                CURRENT BASE REGS                15400000
         DC    0H'0'                                                    15410014
USGLEN   DC    AL2(L'USING) LENGTH OF USING TBL ENTRY                   15420014
NEXCHG   DC    XL3'00'                 NEXT BASE REG CHG OFFSET         15430000
MORUSG   DC    X'00'                   80=CURRENT BASE, 0=NO MORE BASES 15440000
CONTYPE  DC    CL1' '                  TYPE                             15450014
CONLEN   DC    H'0'                    CONSTANT LENGTH                  15460014
CONOFST  DC    F'0'                    RELATIVE OFFSET TO CONSTANT      15470014
CCTYPE   DC    X'00'                   CC SET TYPE OF INSTR SETTING     15480000
*                                                                       15490027
TXTOFST  DC    0F'0'                                                    15500014
         DC    X'0'                                                     15510014
TXTOFSET DC    XL3'0'                  OFFSET TO TEXT BYTE              15520014
*                                                                       15530027
OFFSET   DC    XL3'0'                  OFFSET FROM PGM START            15540014
INSTYP   DC    CL1' '                  INSTRUCTION TYPE                 15550014
TYPE     DC    XL1'0'                  TYPE CODE                        15560014
*                                       0=CSECT, 1=ADCON, 2=CONST       15570000
*                                       E=USING, D=INSTRUCTION          15580000
*                                       C=COMMENT, 9=ENTRY              15590000
*                                       A=EQU                           15600000
LEN      DC    XL1'0'                  TEXT LENGTH                      15610014
TEXT     DC    XL8'0'                  TEXT                             15620014
BLANX    DC    CL121' '                CONSTANT BLANKS                  15630000
UNAME    DC    CL8'A'                  USER NAME AREA                   15640000
XZROS    DC    8X'00'                  CONSTANT ZEROS                   15650000
TRTBL    DC    C'0123456789ABCDEF'     TRANSLATE TBL                    15660000
PRTABL   DC    CL9' '                  PRINTABLE HEX WORK               15670014
*                                                                       15680014
CHARTRAN DC    256X'FF'                TRT TABLE FOR CHAR/HEX DETERMINA 15690000
         ORG   CHARTRAN+C' '                                            15700000
         DC    X'00'                   BLANK IS CHARACTER               15710000
         ORG   CHARTRAN+C'A'                                            15720000
         DC    9X'00'                  A-I ARE CHARACTERS               15730000
         ORG   CHARTRAN+C'J'                                            15740000
         DC    9X'00'                  J-R ARE CHARACTERS               15750000
         ORG   CHARTRAN+C'S'                                            15760000
         DC    8X'00'                  S-Z ARE CHARACTERS               15770000
         ORG   CHARTRAN+C'0'                                            15780000
         DC    10X'00'                 0-9 ARE CHARACTERS               15790000
         ORG                                                            15800000
*                                                                       15810014
TRHEX    DC    256X'FF'                HEX TRANSLATION TABLE            15820000
         ORG   TRHEX+C'A'                                               15830000
         DC    X'0A0B0C0D0E0F'                                          15840000
         ORG   TRHEX+C'0'                                               15850000
         DC    X'00010203040506070809'                                  15860000
         ORG                                                            15870000
*                                                                       15880014
TRTHEX   DC    0X'0'                   VERIFY HEX TABLE                 15890014
         DC    XL16'00'                                                 15900000
         DC    XL240'FF'                                                15910000
         ORG                                                            15920000
*                                                                       15930000
* INSTRUCTION DISASSEMBLY TABLES. THESE TABLES DEFINE VALID             15940000
* INSTRUCTION OP-CODES, AND GIVE MNEMONICS, FORMAT-TYPES,               15950000
* AND AN INDICATOR TO SHOW CONDITION SETTING INSTRUCTIONS,              15960000
* PRIVILEGED INSTRUCTIONS, AND FLOATING POINT INSTRUCTIONS.             15970000
*                                                                       15980014
INSTENT  DS    0CL10                   CURRENT INSTRUCTION ENTRY        15990014
INAME    DC    CL5' '                  INSTR NAME (MNEMONIC)            16000014
ITYPE    DC    XL1'0'                  INSTRUCTION TYPE                 16010014
RR       EQU   0                       RR FORMAT                        16020000
RX       EQU   4                       RX FORMAT                        16030000
S        EQU   8                       S FORMAT                         16040000
SI       EQU   12                      SI FORMAT                        16050000
RS       EQU   16                      RS FORMAT                        16060000
SS1      EQU   20                      SS FORMAT, SINGLE LENGTH         16070000
SS2      EQU   24                      SS FORMAT, 2 LENGTHS             16080000
TWO      EQU   28                      TWO BYTE OP-CODE                 16090000
CONDBR   EQU   32                      CONDITIONAL BRANCH               16100000
SVC      EQU   36                      SUPERVISOR CALL                  16110000
ICLASS   DC    XL1'0'                  INSTRUCTION CLASS                16120014
PRIV     EQU   2                       PRIVILEGED INSTRUCTION           16130000
FLTPT    EQU   4                       FLOATING POINT INSTRUCTION       16140000
FLSHT    EQU   5                       SHORT PREC FLT PT INSTR          16150000
IEDT     DC    XL1'0'                  INSTRUCTION EDITS                16160014
EPR      EQU   X'40'                   EVEN-ODD REGISTER PAIR           16170000
E2       EQU   X'20'                   2ND OPND ON HALFWORD BOUND       16180000
E4       EQU   X'10'                   2ND OPND ON FULLWORD BOUND       16190000
E8       EQU   X'08'                   2ND OPND ON DBL WORD BOUND       16200000
S1       EQU   X'02'                   1ST OPND MUST HAVE BASE/INDEX    16210000
S2       EQU   X'01'                   2ND OPND MUST HAVE BASE          16220000
ICCSET   DC    XL1'0'                  TYPE CONDITION CODE SET          16230014
ARITH    EQU   X'80'                   ARITHMETIC TYPE                  16240000
CPR      EQU   X'40'                   COMPARE TYPE                     16250000
ZRO8     EQU   X'20'                   BC 8 MAY BE BZ                   16260000
INLNG    DC    XL1'0'                  INSTRUCTION LENGTH               16270014
*                                                                       16280000
SGLOP    DS    0CL10                   SINGLE BYTE OP-CODE TABLE        16290000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'02' NOT INSTR      16300000
         DC    CL5' ',AL1(TWO),AL1(0),AL1(0),AL1(0),X'02' 01            16310002
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'02' NOT INSTR      16320000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'02' NOT INSTR      16330000
         DC    CL5'SPM',AL1(RR),AL1(0),AL1(0),AL1(0),X'02' 04           16340000
         DC    CL5'BALR',AL1(RR),AL1(0),AL1(0),AL1(0),X'02' 05          16350000
         DC    CL5'BCTR',AL1(RR),AL1(0),AL1(0),AL1(0),X'02' 06          16360000
         DC    CL5'BCR',AL1(RR),AL1(0),AL1(0),AL1(0),X'02' 07           16370000
         DC    CL5'SSK',AL1(RR),AL1(PRIV),AL1(0),AL1(0),X'02' 08        16380000
         DC    CL5'ISK',AL1(RR),AL1(PRIV),AL1(0),AL1(0),X'02' 09        16390000
         DC    CL5'SVC',AL1(SVC),AL1(0),AL1(0),AL1(0),X'02' 0A          16400000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'02' NOT INSTR      16410000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'02' NOT INSTR      16420000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'02' NOT INSTR      16430000
         DC    CL5'MVCL',AL1(RR),AL1(0),AL1(EPR),AL1(0),X'02' 0E        16440000
         DC    CL5'CLCL',AL1(RR),AL1(0),AL1(EPR),AL1(0),X'02' 0F        16450000
         DC    CL5'LPR',AL1(RR),AL1(0),AL1(0),AL1(ARITH),X'02' 10       16460000
         DC    CL5'LNR',AL1(RR),AL1(0),AL1(0),AL1(ARITH),X'02' 11       16470000
         DC    CL5'LTR',AL1(RR),AL1(0),AL1(0),AL1(ARITH),X'02' 12       16480000
         DC    CL5'LCR',AL1(RR),AL1(0),AL1(0),AL1(ARITH),X'02' 13       16490000
         DC    CL5'NR',AL1(RR),AL1(0),AL1(0),AL1(ZRO8),X'02' 14         16500000
         DC    CL5'CLR',AL1(RR),AL1(0),AL1(0),AL1(CPR),X'02' 15         16510000
         DC    CL5'OR',AL1(RR),AL1(0),AL1(0),AL1(ZRO8),X'02' 16         16520000
         DC    CL5'XR',AL1(RR),AL1(0),AL1(0),AL1(ZRO8),X'02' 17         16530000
         DC    CL5'LR',AL1(RR),AL1(0),AL1(0),AL1(0),X'02' 18            16540000
         DC    CL5'CR',AL1(RR),AL1(0),AL1(0),AL1(CPR),X'02' 19          16550000
         DC    CL5'AR',AL1(RR),AL1(0),AL1(0),AL1(ARITH),X'02' 1A        16560000
         DC    CL5'SR',AL1(RR),AL1(0),AL1(0),AL1(ARITH),X'02' 1B        16570000
         DC    CL5'MR',AL1(RR),AL1(0),AL1(EPR),AL1(0),X'02' 1C          16580000
         DC    CL5'DR',AL1(RR),AL1(0),AL1(EPR),AL1(0),X'02' 1D          16590000
         DC    CL5'ALR',AL1(RR),AL1(0),AL1(0),AL1(0),X'02' 1E           16600000
         DC    CL5'SLR',AL1(RR),AL1(0),AL1(0),AL1(0),X'02' 1F           16610000
         DC    CL5'LPDR',AL1(RR),AL1(FLTPT),AL1(0),AL1(ARITH),X'02' 20  16620000
         DC    CL5'LNDR',AL1(RR),AL1(FLTPT),AL1(0),AL1(ARITH),X'02' 21  16630000
         DC    CL5'LTDR',AL1(RR),AL1(FLTPT),AL1(0),AL1(ARITH),X'02' 22  16640000
         DC    CL5'LCDR',AL1(RR),AL1(FLTPT),AL1(0),AL1(ARITH),X'02' 23  16650000
         DC    CL5'HDR',AL1(RR),AL1(FLTPT),AL1(0),AL1(0),X'02' 24       16660000
         DC    CL5'LRDR',AL1(RR),AL1(FLTPT),AL1(0),AL1(0),X'02' 25      16670000
         DC    CL5'MXR',AL1(RR),AL1(FLTPT),AL1(0),AL1(0),X'02' 26       16680000
         DC    CL5'MXDR',AL1(RR),AL1(FLTPT),AL1(0),AL1(0),X'02' 27      16690000
         DC    CL5'LDR',AL1(RR),AL1(FLTPT),AL1(0),AL1(0),X'02' 28       16700000
         DC    CL5'CDR',AL1(RR),AL1(FLTPT),AL1(0),AL1(CPR),X'02' 29     16710000
         DC    CL5'ADR',AL1(RR),AL1(FLTPT),AL1(0),AL1(ARITH),X'02' 2A   16720000
         DC    CL5'SDR',AL1(RR),AL1(FLTPT),AL1(0),AL1(ARITH),X'02' 2B   16730000
         DC    CL5'MDR',AL1(RR),AL1(FLTPT),AL1(0),AL1(0),X'02' 2C       16740000
         DC    CL5'DDR',AL1(RR),AL1(FLTPT),AL1(0),AL1(0),X'02' 2D       16750000
         DC    CL5'AWR',AL1(RR),AL1(FLTPT),AL1(0),AL1(ARITH),X'02' 2E   16760000
         DC    CL5'SWR',AL1(RR),AL1(FLTPT),AL1(0),AL1(ARITH),X'02' 2F   16770000
         DC    CL5'LPER',AL1(RR),AL1(FLTPT),AL1(0),AL1(ARITH),X'02' 30  16780000
         DC    CL5'LNER',AL1(RR),AL1(FLTPT),AL1(0),AL1(ARITH),X'02' 31  16790000
         DC    CL5'LTER',AL1(RR),AL1(FLTPT),AL1(0),AL1(ARITH),X'02' 32  16800000
         DC    CL5'LCER',AL1(RR),AL1(FLTPT),AL1(0),AL1(ARITH),X'02' 33  16810000
         DC    CL5'HER',AL1(RR),AL1(FLTPT),AL1(0),AL1(0),X'02' 34       16820000
         DC    CL5'LRER',AL1(RR),AL1(FLTPT),AL1(0),AL1(0),X'02' 35      16830000
         DC    CL5'AXR',AL1(RR),AL1(FLTPT),AL1(0),AL1(ARITH),X'02' 36   16840000
         DC    CL5'SXR',AL1(RR),AL1(FLTPT),AL1(0),AL1(ARITH),X'02' 37   16850000
         DC    CL5'LER',AL1(RR),AL1(FLTPT),AL1(0),AL1(0),X'02' 38       16860000
         DC    CL5'CER',AL1(RR),AL1(FLTPT),AL1(0),AL1(CPR),X'02' 39     16870000
         DC    CL5'AER',AL1(RR),AL1(FLTPT),AL1(0),AL1(ARITH),X'02' 3A   16880000
         DC    CL5'SER',AL1(RR),AL1(FLTPT),AL1(0),AL1(ARITH),X'02' 3B   16890000
         DC    CL5'MER',AL1(RR),AL1(FLTPT),AL1(0),AL1(0),X'02' 3C       16900000
         DC    CL5'DER',AL1(RR),AL1(FLTPT),AL1(0),AL1(0),X'02' 3D       16910000
         DC    CL5'AUR',AL1(RR),AL1(FLTPT),AL1(0),AL1(ARITH),X'02' 3E   16920000
         DC    CL5'SUR',AL1(RR),AL1(FLTPT),AL1(0),AL1(ARITH),X'02' 3F   16930000
         DC    CL5'STH',AL1(RX),AL1(0),AL1(E2+S2),AL1(0),X'04' 40       16940000
         DC    CL5'LA',AL1(RX),AL1(0),AL1(0),AL1(0),X'04' 41            16950000
         DC    CL5'STC',AL1(RX),AL1(0),AL1(S2),AL1(0),X'04' 42          16960000
         DC    CL5'IC',AL1(RX),AL1(0),AL1(0),AL1(0),X'04' 43            16970000
         DC    CL5'EX',AL1(RX),AL1(0),AL1(E2+S2),AL1(0),X'04' 44        16980000
         DC    CL5'BAL',AL1(RX),AL1(0),AL1(E2),AL1(0),X'04' 45          16990000
         DC    CL5'BCT',AL1(RX),AL1(0),AL1(E2+S2),AL1(0),X'04' 46       17000000
         DC    CL5'BC',AL1(CONDBR),AL1(0),AL1(E2),AL1(0),X'04' 47       17010000
         DC    CL5'LH',AL1(RX),AL1(0),AL1(E2),AL1(0),X'04' 48           17020000
         DC    CL5'CH',AL1(RX),AL1(0),AL1(E2),AL1(CPR),X'04' 49         17030000
         DC    CL5'AH',AL1(RX),AL1(0),AL1(E2),AL1(ARITH),X'04' 4A       17040000
         DC    CL5'SH',AL1(RX),AL1(0),AL1(E2),AL1(ARITH),X'04' 4B       17050000
         DC    CL5'MH',AL1(RX),AL1(0),AL1(E2),AL1(0),X'04' 4C           17060000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      17070000
         DC    CL5'CVD',AL1(RX),AL1(0),AL1(E8+S2),AL1(0),X'04' 4E       17080000
         DC    CL5'CVB',AL1(RX),AL1(0),AL1(E8),AL1(0),X'04' 4F          17090000
         DC    CL5'ST',AL1(RX),AL1(0),AL1(E4+S2),AL1(0),X'04' 50        17100000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      17110000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      17120000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      17130000
         DC    CL5'N',AL1(RX),AL1(0),AL1(E4),AL1(ZRO8),X'04' 54         17140000
         DC    CL5'CL',AL1(RX),AL1(0),AL1(E4),AL1(CPR),X'04' 55         17150000
         DC    CL5'O',AL1(RX),AL1(0),AL1(E4),AL1(ZRO8),X'04' 56         17160000
         DC    CL5'X',AL1(RX),AL1(0),AL1(E4),AL1(ZRO8),X'04' 57         17170000
         DC    CL5'L',AL1(RX),AL1(0),AL1(E4),AL1(0),X'04' 58            17180000
         DC    CL5'C',AL1(RX),AL1(0),AL1(E4),AL1(CPR),X'04' 59          17190000
         DC    CL5'A',AL1(RX),AL1(0),AL1(E4),AL1(ARITH),X'04' 5A        17200000
         DC    CL5'S',AL1(RX),AL1(0),AL1(E4),AL1(ARITH),X'04' 5B        17210000
         DC    CL5'M',AL1(RX),AL1(0),AL1(E4+EPR),AL1(0),X'04' 5C        17220000
         DC    CL5'D',AL1(RX),AL1(0),AL1(E4+EPR),AL1(0),X'04' 5D        17230000
         DC    CL5'AL',AL1(RX),AL1(0),AL1(E4),AL1(0),X'04' 5E           17240000
         DC    CL5'SL',AL1(RX),AL1(0),AL1(E4),AL1(0),X'04' 5F           17250000
         DC    CL5'STD',AL1(RX),AL1(FLTPT),AL1(0),AL1(0),X'04' 60       17260000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      17270000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      17280000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      17290000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      17300000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      17310000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      17320000
         DC    CL5'MXD',AL1(RX),AL1(FLTPT),AL1(0),AL1(0),X'04' 67       17330000
         DC    CL5'LD',AL1(RX),AL1(FLTPT),AL1(0),AL1(0),X'04' 68        17340000
         DC    CL5'CD',AL1(RX),AL1(FLTPT),AL1(0),AL1(CPR),X'04' 69      17350000
         DC    CL5'AD',AL1(RX),AL1(FLTPT),AL1(0),AL1(ARITH),X'04' 6A    17360000
         DC    CL5'SD',AL1(RX),AL1(FLTPT),AL1(0),AL1(ARITH),X'04' 6B    17370000
         DC    CL5'MD',AL1(RX),AL1(FLTPT),AL1(0),AL1(0),X'04' 6C        17380000
         DC    CL5'DD',AL1(RX),AL1(FLTPT),AL1(0),AL1(0),X'04' 6D        17390000
         DC    CL5'AW',AL1(RX),AL1(FLTPT),AL1(0),AL1(ARITH),X'04' 6E    17400000
         DC    CL5'SW',AL1(RX),AL1(FLTPT),AL1(0),AL1(ARITH),X'04' 6F    17410000
         DC    CL5'STE',AL1(RX),AL1(FLSHT),AL1(0),AL1(0),X'04' 70       17420000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      17430000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      17440000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      17450000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      17460000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      17470000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      17480000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      17490000
         DC    CL5'LE',AL1(RX),AL1(FLSHT),AL1(0),AL1(0),X'04' 78        17500000
         DC    CL5'CE',AL1(RX),AL1(FLSHT),AL1(0),AL1(CPR),X'04' 79      17510000
         DC    CL5'AE',AL1(RX),AL1(FLSHT),AL1(0),AL1(ARITH),X'04' 7A    17520000
         DC    CL5'SE',AL1(RX),AL1(FLSHT),AL1(0),AL1(ARITH),X'04' 7B    17530000
         DC    CL5'ME',AL1(RX),AL1(FLSHT),AL1(0),AL1(0),X'04' 7C        17540000
         DC    CL5'DE',AL1(RX),AL1(FLSHT),AL1(0),AL1(0),X'04' 7D        17550000
         DC    CL5'AU',AL1(RX),AL1(FLSHT),AL1(0),AL1(ARITH),X'04' 7E    17560000
         DC    CL5'SU',AL1(RX),AL1(FLSHT),AL1(0),AL1(ARITH),X'04' 7F    17570000
         DC    CL5'SSM',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04' 80         17580000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      17590000
         DC    CL5'LPSW',AL1(S),AL1(PRIV),AL1(E8),AL1(0),X'04' 82       17600000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      17610000
         DC    CL5'WRD',AL1(SI),AL1(PRIV),AL1(0),AL1(0),X'04' 84        17620000
         DC    CL5'RDD',AL1(SI),AL1(PRIV),AL1(0),AL1(0),X'04' 85        17630000
         DC    CL5'BXH',AL1(RS),AL1(0),AL1(E2+S2),AL1(0),X'04' 86       17640000
         DC    CL5'BXLE',AL1(RS),AL1(0),AL1(E2+S2),AL1(0),X'04' 87      17650000
         DC    CL5'SRL',AL1(RS),AL1(0),AL1(0),AL1(ARITH),X'04' 88       17660000
         DC    CL5'SLL',AL1(RS),AL1(0),AL1(0),AL1(ARITH),X'04' 89       17670000
         DC    CL5'SRA',AL1(RS),AL1(0),AL1(0),AL1(ARITH),X'04' 8A       17680000
         DC    CL5'SLA',AL1(RS),AL1(0),AL1(0),AL1(ARITH),X'04' 8B       17690000
         DC    CL5'SRDL',AL1(RS),AL1(0),AL1(EPR),AL1(ARITH),X'04' 8C    17700000
         DC    CL5'SLDL',AL1(RS),AL1(0),AL1(EPR),AL1(ARITH),X'04' 8D    17710000
         DC    CL5'SRDA',AL1(RS),AL1(0),AL1(EPR),AL1(ARITH),X'04' 8E    17720000
         DC    CL5'SLDA',AL1(RS),AL1(0),AL1(EPR),AL1(ARITH),X'04' 8F    17730000
         DC    CL5'STM',AL1(RS),AL1(0),AL1(E4+S2),AL1(0),X'04' 90       17740000
         DC    CL5'TM',AL1(SI),AL1(0),AL1(0),AL1(ARITH),X'04' 91        17750000
         DC    CL5'MVI',AL1(SI),AL1(0),AL1(S2),AL1(0),X'04' 92          17760000
         DC    CL5'TS',AL1(S),AL1(0),AL1(0),AL1(0),X'04' 93             17770000
         DC    CL5'NI',AL1(SI),AL1(0),AL1(0),AL1(ZRO8),X'04' 94         17780000
         DC    CL5'CLI',AL1(SI),AL1(0),AL1(0),AL1(CPR),X'04' 95         17790000
         DC    CL5'OI',AL1(SI),AL1(0),AL1(0),AL1(ZRO8),X'04' 96         17800000
         DC    CL5'XI',AL1(SI),AL1(0),AL1(0),AL1(ZRO8),X'04' 97         17810000
         DC    CL5'LM',AL1(RS),AL1(0),AL1(E4),AL1(0),X'04' 98           17820000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      17830000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      17840000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      17850000
         DC    CL5' ',AL1(TWO),AL1(0),AL1(0),AL1(0),X'04' 9C            17860000
         DC    CL5' ',AL1(TWO),AL1(0),AL1(0),AL1(0),X'04' 9D            17870000
         DC    CL5' ',AL1(TWO),AL1(0),AL1(0),AL1(0),X'04' 9E            17880000
         DC    CL5' ',AL1(TWO),AL1(0),AL1(0),AL1(0),X'04' 9F            17890000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      17900000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      17910000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      17920000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      17930000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      17940000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      17950000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      17960000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      17970000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      17980000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      17990000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      18000000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      18010000
         DC    CL5'STNSM',AL1(SI),AL1(PRIV),AL1(0),AL1(0),X'04' AC      18020000
         DC    CL5'STOSM',AL1(SI),AL1(PRIV),AL1(0),AL1(0),X'04' AD      18030000
         DC    CL5'SIGP',AL1(RS),AL1(PRIV),AL1(0),AL1(0),X'04' AE       18040000
         DC    CL5'MC',AL1(SI),AL1(0),AL1(0),AL1(0),X'04' AF            18050000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      18060000
         DC    CL5'LRA',AL1(RX),AL1(PRIV),AL1(0),AL1(0),X'04' B1        18070000
         DC    CL5' ',AL1(TWO),AL1(0),AL1(0),AL1(0),X'04' B2            18080000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      18090000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      18100000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      18110000
         DC    CL5'STCTL',AL1(RS),AL1(PRIV),AL1(0),AL1(0),X'04' B6      18120000
         DC    CL5'LCTL',AL1(RS),AL1(PRIV),AL1(E4),AL1(0),X'04' B7      18130000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      18140000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      18150000
         DC    CL5'CS',AL1(RS),AL1(0),AL1(E4+EPR),AL1(0),X'04' BA       18160000
         DC    CL5'CDS',AL1(RS),AL1(0),AL1(E4+EPR),AL1(0),X'04' BB      18170000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      18180000
         DC    CL5'CLM',AL1(RS),AL1(0),AL1(0),AL1(CPR),X'04' BD         18190000
         DC    CL5'STCM',AL1(RS),AL1(0),AL1(S2),AL1(0),X'04' BE         18200000
         DC    CL5'ICM',AL1(RS),AL1(0),AL1(0),AL1(ZRO8),X'04' BF        18210000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      18220000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      18230000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      18240000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      18250000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      18260000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      18270000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      18280000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      18290000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      18300000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      18310000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      18320000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      18330000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      18340000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      18350000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      18360000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      18370000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      18380000
         DC    CL5'MVN',AL1(SS1),AL1(0),AL1(S1),AL1(0),X'06' D1         18390000
         DC    CL5'MVC',AL1(SS1),AL1(0),AL1(S1),AL1(0),X'06' D2         18400000
         DC    CL5'MVZ',AL1(SS1),AL1(0),AL1(S1),AL1(0),X'06' D3         18410000
         DC    CL5'NC',AL1(SS1),AL1(0),AL1(S1),AL1(ZRO8),X'06' D4       18420000
         DC    CL5'CLC',AL1(SS1),AL1(0),AL1(0),AL1(CPR),X'06' D5        18430000
         DC    CL5'OC',AL1(SS1),AL1(0),AL1(S1),AL1(ZRO8),X'06' D6       18440000
         DC    CL5'XC',AL1(SS1),AL1(0),AL1(S1),AL1(ZRO8),X'06' D7       18450000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      18460000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      18470000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      18480000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      18490000
         DC    CL5'TR',AL1(SS1),AL1(0),AL1(S1),AL1(0),X'06' DC          18500000
         DC    CL5'TRT',AL1(SS1),AL1(0),AL1(0),AL1(ZRO8),X'06' DD       18510000
         DC    CL5'ED',AL1(SS1),AL1(0),AL1(S1),AL1(ARITH),X'06' DE      18520000
         DC    CL5'EDMK',AL1(SS1),AL1(0),AL1(S1),AL1(ARITH),X'06' DF    18530000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      18540000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      18550000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      18560000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      18570000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      18580000
         DC    CL5' ',AL1(TWO),AL1(0),AL1(0),AL1(0),X'04' E5            18590002
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      18600000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      18610000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      18620000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      18630000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      18640000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      18650000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      18660000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      18670000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      18680000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      18690000
         DC    CL5'SRP',AL1(SS2),AL1(0),AL1(S1),AL1(ARITH),X'06' F0     18700000
         DC    CL5'MVO',AL1(SS2),AL1(0),AL1(S1),AL1(0),X'06' F1         18710000
         DC    CL5'PACK',AL1(SS2),AL1(0),AL1(S1),AL1(0),X'06' F2        18720000
         DC    CL5'UNPK',AL1(SS2),AL1(0),AL1(S1),AL1(0),X'06' F3        18730000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      18740000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      18750000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      18760000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      18770000
         DC    CL5'ZAP',AL1(SS2),AL1(0),AL1(S1),AL1(ARITH),X'06' F8     18780000
         DC    CL5'CP',AL1(SS2),AL1(0),AL1(0),AL1(CPR),X'06' F9         18790000
         DC    CL5'AP',AL1(SS2),AL1(0),AL1(S1),AL1(ARITH),X'06' FA      18800000
         DC    CL5'SP',AL1(SS2),AL1(0),AL1(S1),AL1(ARITH),X'06' FB      18810000
         DC    CL5'MP',AL1(SS2),AL1(0),AL1(S1),AL1(0),X'06' FC          18820000
         DC    CL5'DP',AL1(SS2),AL1(0),AL1(S1),AL1(0),X'06' FD          18830000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      18840000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      18850000
         DC    X'FFFF'                 TABLE END                        18860000
*                                                                       18870000
DBLOP    DS    0CL12                   TWO-BYTE OP-CODE TABLE           18880000
         DC    X'0101',CL5'PR   ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     18890002
         DC    X'0102',CL5'UPT  ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     18900002
         DC    X'9C00',CL5'SIO  ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  18910002
         DC    X'9C01',CL5'SIOF ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  18920002
         DC    X'9D00',CL5'TIO  ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  18930002
         DC    X'9D01',CL5'CLRIO',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  18940002
         DC    X'9E00',CL5'HIO  ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  18950002
         DC    X'9E01',CL5'HDV  ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  18960002
         DC    X'9F00',CL5'TCH  ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  18970002
         DC    X'B202',CL5'STIDP',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  18980002
         DC    X'B203',CL5'STIDC',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  18990002
         DC    X'B204',CL5'SCK  ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  19000002
         DC    X'B205',CL5'STCK ',AL1(S),AL1(0),AL1(E8+S2),AL1(0),X'04' 19010002
         DC    X'B206',CL5'SCKC ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  19020002
         DC    X'B207',CL5'STCKC',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  19030002
         DC    X'B208',CL5'SPT  ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  19040002
         DC    X'B209',CL5'STPT ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  19050002
         DC    X'B20A',CL5'SPKA ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  19060002
         DC    X'B20B',CL5'IPK  ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  19070002
         DC    X'B20D',CL5'PTLB ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  19080002
         DC    X'B210',CL5'SPX  ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  19090002
         DC    X'B211',CL5'STPX ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  19100002
         DC    X'B212',CL5'STAP ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  19110002
         DC    X'B213',CL5'RRB  ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  19120002
         DC    X'B214',CL5'SIE  ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  19130002
         DC    X'B218',CL5'PC   ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     19140002
         DC    X'B219',CL5'SAC  ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     19150002
         DC    X'B21A',CL5'CFC  ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     19160002
         DC    X'B221',CL5'IPTE ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  19170002
         DC    X'B222',CL5'IPM  ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     19180002
         DC    X'B223',CL5'IVSK ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     19190002
         DC    X'B224',CL5'IAC  ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     19200002
         DC    X'B225',CL5'SSAR ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     19210002
         DC    X'B226',CL5'EPAR ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     19220002
         DC    X'B227',CL5'ESAR ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     19230002
         DC    X'B228',CL5'PT   ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     19240002
         DC    X'B229',CL5'ISKE ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  19250002
         DC    X'B22A',CL5'RRBE ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  19260002
         DC    X'B22B',CL5'SSKE ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  19270002
         DC    X'B22C',CL5'TB   ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  19280002
         DC    X'B22D',CL5'DXR  ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     19290002
         DC    X'B230',CL5'CSCH ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  19300002
         DC    X'B231',CL5'HSCH ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  19310002
         DC    X'B232',CL5'MSCH ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  19320002
         DC    X'B233',CL5'SSCH ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  19330002
         DC    X'B234',CL5'STSCH',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  19340002
         DC    X'B235',CL5'TSCH ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  19350002
         DC    X'B236',CL5'TPI  ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  19360002
         DC    X'B237',CL5'SAL  ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  19370002
         DC    X'B238',CL5'RSCH ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  19380002
         DC    X'B239',CL5'STCRW',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  19390002
         DC    X'B23A',CL5'STCPS',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  19400002
         DC    X'B23B',CL5'RCHP ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  19410002
         DC    X'B240',CL5'BAKR ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     19420002
         DC    X'B244',CL5'SQDR ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     19430002
         DC    X'B245',CL5'SQER ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     19440002
         DC    X'B246',CL5'STURA',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  19450002
         DC    X'B247',CL5'MSTA ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     19460002
         DC    X'B248',CL5'PALB ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  19470002
         DC    X'B249',CL5'EREG ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     19480002
         DC    X'B24A',CL5'ESTA ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     19490002
         DC    X'B24B',CL5'LURA ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  19500002
         DC    X'B24C',CL5'TAR  ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     19510002
         DC    X'B24D',CL5'CPYA ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     19520002
         DC    X'B24E',CL5'SAR  ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     19530002
         DC    X'B24F',CL5'EAR  ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     19540002
         DC    X'B254',CL5'MVPG ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     19550002
         DC    X'B255',CL5'MVST ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     19560002
         DC    X'B257',CL5'CUSE ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     19570002
         DC    X'B258',CL5'BSG  ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     19580002
         DC    X'B25D',CL5'CLST ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     19590002
         DC    X'B25E',CL5'SRST ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     19600002
         DC    X'B279',CL5'SACF ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     19610003
         DC    X'E500',CL5'LASP ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  19620002
         DC    X'E501',CL5'TPROT',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     19630002
         DC    X'E50E',CL5'MVCSK',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     19640002
         DC    X'E50F',CL5'MVCDK',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     19650002
         DC    X'FFFF'                 TABLE END                        19660000
*                                                                       19670000
SVCOP    DS    0CL15                   SVC NAME TABLE                   19680000
         DC    AL1(0),CL14'EXCP/XDAP'                                   19690000
         DC    AL1(1),CL14'WAIT/WAITR'                                  19700000
         DC    AL1(2),CL14'POST/PRTOV'                                  19710000
         DC    AL1(3),CL14'EXIT'                                        19720002
         DC    AL1(4),CL14'GETMAIN'                                     19730000
         DC    AL1(5),CL14'FREEMAIN'                                    19740000
         DC    AL1(6),CL14'LINK'                                        19750002
         DC    AL1(7),CL14'XCTL'                                        19760002
         DC    AL1(8),CL14'LOAD'                                        19770002
         DC    AL1(9),CL14'DELETE'                                      19780000
         DC    AL1(10),CL14'GET/FREEMAIN R'                             19790000
         DC    AL1(11),CL14'TIME'                                       19800000
         DC    AL1(12),CL14'SYNCH'                                      19810000
         DC    AL1(13),CL14'ABEND'                                      19820000
         DC    AL1(14),CL14'SPIE'                                       19830000
         DC    AL1(15),CL14'ERREXCP'                                    19840000
         DC    AL1(16),CL14'PURGE'                                      19850000
         DC    AL1(17),CL14'RESTORE'                                    19860000
         DC    AL1(18),CL14'BLDL/FIND'                                  19870000
         DC    AL1(19),CL14'OPEN'                                       19880000
         DC    AL1(20),CL14'CLOSE'                                      19890000
         DC    AL1(21),CL14'STOW'                                       19900000
         DC    AL1(22),CL14'OPEN TYPE J'                                19910000
         DC    AL1(23),CL14'CLOSE TYPE T'                               19920000
         DC    AL1(24),CL14'DEVTYPE'                                    19930000
         DC    AL1(25),CL14'TRKBAL'                                     19940000
         DC    AL1(26),CL14'LOCATE, ETC'                                19950000
         DC    AL1(27),CL14'OBTAIN'                                     19960000
         DC    AL1(28),CL14'CVOL'                                       19970000
         DC    AL1(29),CL14'SCRATCH'                                    19980000
         DC    AL1(30),CL14'RENAME'                                     19990000
         DC    AL1(31),CL14'FEOV'                                       20000000
         DC    AL1(32),CL14'(NO MACRO)'                                 20010000
         DC    AL1(33),CL14'IOHALT'                                     20020000
         DC    AL1(34),CL14'MGCR/QEDIT'                                 20030000
         DC    AL1(35),CL14'WTO/WTOR'                                   20040000
         DC    AL1(36),CL14'WTL'                                        20050002
         DC    AL1(37),CL14'SEGLD/SEGWT'                                20060000
         DC    AL1(39),CL14'LABEL'                                      20070000
         DC    AL1(40),CL14'EXTRACT'                                    20080000
         DC    AL1(41),CL14'IDENTIFY'                                   20090000
         DC    AL1(42),CL14'ATTACH'                                     20100000
         DC    AL1(43),CL14'CIRB'                                       20110000
         DC    AL1(44),CL14'CHAP'                                       20120000
         DC    AL1(45),CL14'OVLYBRCH'                                   20130000
         DC    AL1(46),CL14'TTIMER'                                     20140000
         DC    AL1(47),CL14'STIMER'                                     20150000
         DC    AL1(48),CL14'DEQ'                                        20160000
         DC    AL1(51),CL14'SNAP/SDUMP'                                 20170000
         DC    AL1(52),CL14'RESTART'                                    20180000
         DC    AL1(53),CL14'RELEX'                                      20190000
         DC    AL1(54),CL14'DISABLE'                                    20200000
         DC    AL1(55),CL14'EOV'                                        20210000
         DC    AL1(56),CL14'ENQ/RESERVE'                                20220000
         DC    AL1(57),CL14'FREEDBUF'                                   20230000
         DC    AL1(58),CL14'RELBUF/REQBUF'                              20240000
         DC    AL1(59),CL14'OLTEP'                                      20250000
         DC    AL1(60),CL14'(E)STAE/STAI'                               20260000
         DC    AL1(61),CL14'IKJEGS6A'                                   20270000
         DC    AL1(62),CL14'DETACH'                                     20280000
         DC    AL1(63),CL14'CHKPT'                                      20290000
         DC    AL1(64),CL14'RDJFCB'                                     20300000
         DC    AL1(66),CL14'BTAMTEST'                                   20310000
         DC    AL1(67),CL14'SYNADAF'                                    20320000
         DC    AL1(68),CL14'SYNADRLS'                                   20330000
         DC    AL1(69),CL14'BSP'                                        20340000
         DC    AL1(70),CL14'GSERV'                                      20350000
         DC    AL1(71),CL14'ASGNBFR, ETC'                               20360000
         DC    AL1(72),CL14'CHATR'                                      20370000
         DC    AL1(73),CL14'SPAR'                                       20380000
         DC    AL1(74),CL14'DAR'                                        20390000
         DC    AL1(75),CL14'DQUEUE'                                     20400000
         DC    AL1(76),CL14'(NO MACRO)'                                 20410000
         DC    AL1(78),CL14'(NO MACRO)'                                 20420000
         DC    AL1(79),CL14'STATUS'                                     20430000
         DC    AL1(81),CL14'SETPRT'                                     20440000
         DC    AL1(82),CL14'DASDR'                                      20450000
         DC    AL1(83),CL14'SMFWTM'                                     20460000
         DC    AL1(84),CL14'GRAPHICS'                                   20470000
         DC    AL1(85),CL14'DDRSWAP'                                    20480000
         DC    AL1(86),CL14'ATLAS'                                      20490000
         DC    AL1(87),CL14'DOM'                                        20500000
         DC    AL1(88),CL14'MOD88'                                      20510000
         DC    AL1(91),CL14'VOLSTAT'                                    20520000
         DC    AL1(92),CL14'TCBEXCP'                                    20530000
         DC    AL1(93),CL14'TGET/TPUT'                                  20540000
         DC    AL1(94),CL14'STCC'                                       20550000
         DC    AL1(95),CL14'SYSEVENT'                                   20560000
         DC    AL1(96),CL14'STAX'                                       20570000
         DC    AL1(97),CL14'TSO TEST'                                   20580000
         DC    AL1(98),CL14'PROTECT'                                    20590000
         DC    AL1(99),CL14'DDDYNAM'                                    20600000
         DC    AL1(100),CL14'IKJEFFIB'                                  20610003
         DC    AL1(101),CL14'QTIP'                                      20620003
         DC    AL1(102),CL14'AQCTL'                                     20630003
         DC    AL1(103),CL14'XLATE'                                     20640003
         DC    AL1(104),CL14'TOPCTL'                                    20650003
         DC    AL1(105),CL14'IMAGLIB'                                   20660003
         DC    AL1(107),CL14'MODESET'                                   20670003
         DC    AL1(109),CL14'ESR TYPE 4'                                20680003
         DC    AL1(110),CL14'DSTATUS'                                   20690003
         DC    AL1(111),CL14'(NO MACRO)'                                20700003
         DC    AL1(112),CL14'PGRLSE'                                    20710003
         DC    AL1(113),CL14'PGFIX ETC'                                 20720003
         DC    AL1(114),CL14'EXCPVR'                                    20730000
         DC    AL1(116),CL14'ESR TYPE 1'                                20740000
         DC    AL1(117),CL14'DEBCHK'                                    20750000
         DC    AL1(119),CL14'TESTAUTH'                                  20760000
         DC    AL1(120),CL14'GETMAIN/FREEMAIN'                          20770000
         DC    AL1(121),CL14'VSAM'                                      20780000
         DC    AL1(122),CL14'EVENTS'                                    20790000
         DC    AL1(123),CL14'PURGEDQ'                                   20800000
         DC    AL1(124),CL14'TPIO'                                      20810000
         DC    AL1(125),CL14'EVENTS'                                    20820000
         DC    AL1(126),CL14'MSS INTERFACE'                             20830000
         DC    X'FF'                   END OF TABLE                     20840000
         DC    (((((*-UTL31P1)/256)+1)*256)-(*-UTL31P1))X'00'           20850014
UTL31P1Z DC    0D'0'                                                    20860014
******************************************************************      20870014
*                                                                *      20880014
* FOLLOWING FIELDS: COMMPARM THRU COMMEND ARE COMMON AREAS SHARED       20890014
* BY THIS, AND CALLED SUB-PROGRAMS. ALL CHANGES MUST BE COORDINTAED     20900014
* WITH ALL OTHER PROGRAMS.                                              20910014
*                                                                       20920014
******************************************************************      20930014
COMMPARM DSECT ,                       COMMON AREAS                     20940014
DBLWD    DS    D                       DOUBLEWORD WORK AREA             20950014
PUNCHDCB DS    F                       @ SYSPUNCH DCB                   20960014
PRINTDCB DS    F                       @ SYSPRINT DCB                   20970014
INDCB    DS    F                       @ SYSIN DCB                      20980014
CSECT    DS    CL8                     SPECIFIED CSECT NAME             20990014
ESDID    DS    XL2                     ESD ID OF SPECIFIED CSECT        21000014
ENDLBLNM DS    CL8                     SYMBOL FOR END STMT BEGIN POINTE 21010014
LINECT   DS    PL2                     PRINT LINE COUNTER               21020014
START    DS    A                       LKED ASSIGNED START ADDR OF CSEC 21030014
END      DS    A                       CSECT END ADDRESS                21040014
LENGTH   DS    F                       LENGTH OF SPECIFIED CSECT        21050014
LBLTBL   DS    F                       @ LABEL TABLE                    21060014
CURRLBL  DS    F                       CURRENT LABEL ENTRY ADDR         21070014
ENDLBL   DS    F                       @ END OF LABEL TBL               21080014
LBLLGTH  DS    AL2                     LENGTH OF LABEL ENTRY            21090014
TXTSTRT  DS    F                       @ TEXT STORAGE AREA              21100014
TXTEND   DS    F                       @ END OF TEXT AREA               21110014
TXTCURR  DS    F                       @ CURRENT TEXT LOC               21120014
DTBCURR  DS    F                       @ CURRENT DSECT TBL ENTRY        21130014
DTBEND   DS    F                       @ DSECT TBL END                  21140014
DTBSTRT  DS    F                       @ DSECT TBL START                21150014
USGSTRT  DS    F                       @ USING TBL START                21160014
USGCUR   DS    F                       @ CURRENT USING TBL ENTRY        21170014
USGEND   DS    F                       @ USING TBL END                  21180014
DATONLY  DS    F                       @ DATA ONLY TABLE                21190014
DATOCUR  DS    F                       @ CURRENT DATA ONLY ENTRY        21200014
DATOEND  DS    F                       @ END OF DATA ONLY TABLE         21210014
PRMOPT   DS    X                                                    DSK 21220014
FLPTASM  EQU   X'80'                   FLOATING POINT INDICATOR     DSK 21230014
PRIVASM  EQU   X'40'                   PRIVILEGED INDICATOR         DSK 21240014
DBGINSTR EQU   X'20'                   DEBUG(INSTR)                 DSK 21250014
DBGCONST EQU   X'10'                   DEBUG(CONST)                 DSK 21260014
DBGNOCMT EQU   X'08'                   DEBUG(NOCMT)                 DSK 21270014
DBGLABEL EQU   X'04'                   DEBUG(LABEL)                 DSK 21280014
         DS    X                                                    DSK 21290014
USERR    DS    XL1                     ERROR INDIC FOR DISASM1          21300014
NBRLBLS  DS    H                       NBR LABELS FROM DISASM1          21310014
*                                                                       21320014
WORKREC  DS    0CL80                   DISASSEMBLY WORK AREA            21330014
NAME     DS    CL8                     NAME                             21340014
         DS    CL1                                                      21350014
MNEMONIC DS    CL5                     INSTRUCTION MNEMONIC             21360014
         DS    CL1                                                      21370014
OPNDS    DS    CL27                    1ST OPERAND                      21380014
         DS    CL1                                                      21390014
COMMENT  DS    CL28                    COMMENT                          21400014
COL72    DS    CL1                     CONTINUATION COLUMN              21410014
SEQNBR   DS    CL8                     CARD SEQUENCE NBR                21420014
*                                                                       21430014
CARDNO   DS    PL4                     CURRENT OUTPUT CARD NBR          21440014
*                                                                       21450014
PRTLINE  DS    0CL121                  PRINT LINE                       21460014
PCC      DS    CL1                     CARRIAGE CONTROL                 21470014
PRT      DS    CL120                   PRINT DATA                       21480014
*                                                                       21490014
         DS    0F                                                       21500014
BLDLIST  DS    0CL62                   BLDL LIST                        21510014
         DC    H'1'                    ONE ENTRY                        21520014
         DC    H'58'                   LENGTH OF ENTRY                  21530014
MEMBER   DC    CL8' '                  MEMBER NAME                      21540014
TTRMOD   DC    XL3'000000'             TTR OF MODULE                    21550014
CCAT     DC    XL1'00'                 CONCATENATION NUMBER             21560014
         DC    XL1'00'                                                  21570014
ALIASIND DC    XL1'00'                 ALIAS AND MISC INDICATOR         21580014
*                           80=ALIAS                                    21590014
TTR1TXT  DC    XL3'000000'             TTR OF 1ST TXT RECORD            21600014
         DC    XL1'00'                                                  21610014
TTRNS    DC    XL3'000000'             TTR OF NOTE OR SCATTER LIST      21620014
NNOTE    DC    XL1'00'                 NBR ENTRIES IN NOTE LIST         21630014
ATTR1A   DC    XL1'00'                 MODULE ATTRIBUTES 1, BYTE 1      21640014
*                           80=RENT                                     21650014
*                           40=REUS                                     21660014
*                           20=OVERLAY                                  21670014
*                           10=UNDER TEST                               21680014
*                           08=ONLY LOADABLE                            21690014
*                           04=SCATTER FORMAT                           21700014
*                           02=EXECUTABLE                               21710014
*                           01=ONE TXT, NO RLD RECORDS                  21720014
ATTR1B   DC    XL1'00'                 ATTRIBUTES 1, BYTE 2             21730014
*                           80=CANNOT BE REPROCESSED BY LKED E          21740014
*                           40=ORIGIN OF 1ST TXT RECORD IS ZERO         21750014
*                           20=ASSIGNED ENTRY POINT ADDR IS ZERO        21760014
*                           10=CONTAINS NO RLD RECORD                   21770014
*                           08=CANNOT BE REPROCESSED BY LKED            21780014
*                           04=CONTAINS TESTRAN SYMBOLS                 21790014
*                           02=CREATED BY LKED                          21800014
*                           01=REFR                                     21810014
TOTVIRT  DC    XL3'000000'             TOTAL VIRTUAL STRG REQRD FOR MOD 21820014
LENG1    DC    XL2'0000'               LENGTH OF 1ST TEXT RECORD        21830014
LKEPA    DC    XL3'000000'             ASSIGNED ENTRY POINT ADDR        21840014
ATTR2    DC    XL1'00'                 ATTRIBUTES 2                     21850014
*                           80=PROCESSED BY OS/VS LKED                  21860014
*                           20=PAGE ALIGNMENT REQUIRED FOR MODULE       21870014
*                           10=SSI PRESENT                              21880014
         DC    XL2'0000'                                                21890014
SCTRLEN  DC    XL2'0000'               SCATTER LIST LENGTH              21900014
TTLEN    DC    XL2'0000'               TRANSLATION TABLE LENGTH         21910014
SCESDID  DC    XL2'0000'               CESD NBR FOR 1ST TXT RECD        21920014
SCEPESD  DC    XL2'0000'               CESD NBR FOR ENTRY POINT         21930014
ALEPA    DC    XL3'000000'             ENTRY POINT OF THE MEMBER NAME   21940014
ALMEM    DC    CL8' '                  REAL MEMBER NAME FOR ALIAS       21950014
SSI      DS    XL4'00000000'           SSI BYTES                        21960014
AUTHLEN  DC    XL1'00'                 AUTH CODE LENGTH                 21970014
AUTHCOD  DC    XL1'00'                 AUTH CODE                        21980014
*                                                                       21990014
COMMEND  EQU   *                                                        22000014
******************************************************************      22010014
*                                                                *      22020014
*                                                                *      22030014
*                                                                *      22040014
******************************************************************      22050014
LABELD   DSECT ,                       LABEL TABLE ENTRY                22060014
LABEL    DS    0CL13                   13-BYTE ENTRIES                  22070014
LBLADR   DS    XL3                     RELATIVE ADDR IN TEXT            22080014
LBLTYP   DS    CL1                     TYPE:                            22090019
LBLTYPL  EQU   C'L'                          L=LABEL                    22100026
LBLTYPA  EQU   C'A'                          A=ADCON                    22110019
LBLTYPV  EQU   C'V'                          V=VCON                     22120019
LBLTYPW  EQU   C'W'                          W=WXTRN                    22130021
LBLTYPU  EQU   C'U'                          U=USER LABEL               22140019
LBLNAME  DS    CL8                     NAME (SYMBOL)                    22150014
LBLLEN   DS    XL1                     LENGTH IF A, V, OR W             22160014
******************************************************************      22170014
*                                                                *      22180014
*                                                                *      22190014
*                                                                *      22200014
******************************************************************      22210014
USINGD   DSECT ,                       USING TABLE ENTRY                22220014
USING    DS    0CL11                                                    22230014
USBGN    DS    XL3                     OFFSET TO BEGINNING OF RANGE     22240014
USEND    DS    XL3                     OFFSET TO END OF RANGE           22250014
USREG    DS    XL1                     BASE REGISTER USED               22260014
USTYPE   DS    XL1                     TYPE:P=PGM,D=DSECT               22270014
USVALU   DS    XL3                     BASE REG VALUE                   22280014
******************************************************************      22290014
*                                                                *      22300014
*                                                                *      22310014
*                                                                *      22320014
******************************************************************      22330014
DSECTD   DSECT ,                       DSECT FIELD TABLE ENTRY          22340014
DSECT    DS    0CL13                                                    22350014
DSOFSET  DS    XL3                     OFFSET TO 1ST BYTE OF FIELD      22360014
DSLBTYP  DS    CL1                     LABEL TYPE = L                   22370014
DSNAME   DS    CL8                     FIELD NAME                       22380014
DSLENG   DS    XL1                     FIELD LENGTH                     22390014
******************************************************************      22400014
*                                                                *      22410014
*                                                                *      22420014
*                                                                *      22430014
******************************************************************      22440014
DTBD     DSECT ,                       DSECT TABLE ENTRY                22450014
DTB      DS    0CL11                                                    22460014
DTBNAM   DS    XL8                     DSECT NAME                       22470014
DTBFLD@  DS    AL3                     DSECT FIELD TABLE ADDRESS        22480014
****************************************************************        22490015
*                                                              *        22500015
*                                                              *        22510015
*                                                              *        22520015
****************************************************************        22530015
DTAD     DSECT ,                       DATA TABLE ENTRY                 22540015
DTA      DS    0XL6                                                     22550015
DTABGN   DS    AL3                     DATA BEGIN OFFSET                22560015
DTAEND   DS    AL3                     DATA END OFFSET                  22570015
         END                                                            22580000
