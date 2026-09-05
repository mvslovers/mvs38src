         TITLE '*** DISASSEMBLY PHASE 2 ***'                            00010053
*                                                                       00020000
* THIS SUB-PROGRAM IS CALLED BY DISASM AFTER THE DIRECTORY              00030000
* ENTRY AND LOAD MODULE ARE PROCESSED. THE ESD AND RLD                  00040000
* ENTRIES HAVE BEEN USED TO CREATE A PROGRAM LABEL TABLE,               00050000
* AND MODULE TEXT IS IN AN AREA OF STORAGE. A COMMON PARAMETER          00060000
* AREA IS DEFINED IN DISASM, AND PASSED TO THIS PROGRAM.                00070000
*                                                                       00080000
* TEXT BYTES ARE USED TO CREATE ASSEMBLY LANGUAGE STATEMENTS,           00090000
* AND MACHINE INSTRUCTION STATEMENTS. OUTPUT IS WRITTEN                 00100000
* TO THE WORK1 DATASET FOR FURTHER PROCESSING BY OTHER                  00110000
* MODULES.                                                              00120000
*   A TEXT BYTE IS CONSIDERED TO BE AN INSTRUCTION IF                   00130000
* IT OCCURS ON A HALFWORD BOUNDARY, IS A VALID OP-CODE,                 00140000
* AND IS FOLLOWED BY A VALID OP-CODE. UNCONDITIONAL BRANCHES            00150000
* NEED NOT BE FOLLOWED BY A VALID OP-CODE, HOWEVER. THE                 00160000
* PRIVILEGED AND FLOATING POINT INSTRUCTIONS ARE NOT                    00170000
* TREATED AS INSTRUCTIONS UNLESS THE USER SPECIFIED                     00180000
* THEIR INCLUSION AT EXEC TIME.                                         00190000
*                                                                       00200000
*                                                                       00210000
* AUTHOR R THORNTON - NOV 1977                                          00220000
*                                                                       00230000
*                                                                       00240000
UTL31P2  CSECT ,                       NAME OF PROGRAM                  00250049
*                                                                       00260049
***REGISTER EQUATES***                                                  00270049
*                                                                       00280049
R0       EQU   0                                                        00290049
R1       EQU   1                                                        00300049
R2       EQU   2                                                        00310049
R3       EQU   3                                                        00320049
R4       EQU   4                                                        00330049
R5       EQU   5                                                        00340049
R6       EQU   6                                                        00350049
R7       EQU   7                                                        00360049
R8       EQU   8                                                        00370049
R9       EQU   9                                                        00380049
R10      EQU   10                                                       00390049
R11      EQU   11                                                       00400049
R12      EQU   12                                                       00410049
R13      EQU   13                                                       00420049
R14      EQU   14                                                       00430049
R15      EQU   15                                                       00440049
*                                                                       00450049
*******************  PROGRAM INITIALIZATION  *************************  00460049
*                                                                       00470049
         USING *,R15                                                    00480049
         B     UTL31BGN                                                 00490049
         DROP  R15                                                      00500049
         DC    AL1(L'UTL31ID)                                           00510049
UTL31ID  DC    CL8'UTL31P2'            PROGRAM ID                       00520049
UTL31BGN DS    0H                                                       00530049
         STM   R14,R12,12(R13)         STORE REGS IN HIGH SAVE AREA     00540049
         LR    R3,R15                  INITIALIZE BASE REG              00550049
         LA    R4,4095(,R3)            INITIALIZE THE SECOND            00560049
         LA    R4,1(,R4)               BASE REGISTER                    00570049
         USING UTL31P2,R3,R4                                            00580049
*                                                                       00590049
***GET MAIN STORAGE FOR SAVE AREA***                                    00600049
*                                                                       00610049
         LA    R0,72                   GET 72 BYTES                     00620049
         GETMAIN R,LV=(0)              GET A SAVE AREA                  00630049
*                                                                       00640049
***SET UP SAVE AREA POINTERS***                                         00650049
*                                                                       00660049
         ST    R1,8(,R13)              STORE LOW SAVE POINTER           00670049
         ST    R1,8(,R13)              STORE LOW SAVE POINTER           00680049
         ST    R13,4(,R1)              STORE HIGH SAVE POINTER          00690049
         LR    R13,R1                  INITIALIZE SAVE POINTER          00700049
         L     R1,4(,R13)              GET POINTER TO RESTORE PARA REG  00710049
         L     R1,24(,R1)              RESTORE PARAMETER REGISTER       00720049
*                                                                       00730049
******************************************************************      00740000
*                                                                *      00750000
* CHECK IF USER WISHES FLOATING POINT AND PRIVILEGED INSTRUCTIONS*      00760000
* IF NOT, CLEAR THE APPROPRIATE ENTRIES IN THE INSTRUCTION OP    *      00770000
* CODE TABLES.                                                   *      00780000
*                                                                *      00790000
******************************************************************      00800000
         L     R5,0(,R1)               GET PARM FIELD ADDRESS           00810036
         USING COMMPARM,R5                                              00820000
         TM    PRMOPT,CONNOLOW         No lower case in DC constant DSK 00830033
         BNO   SKPLOWER                No, keep table               DSK 00840033
         L     R1,=A(CHARTRAN)                                      DSK 00850036
         MVI   C'a'(R1),X'FF'          Clear a-z slots in table     DSK 00860036
         MVC   C'a'+1(C'z'-C'a',R1),C'a'(R1)                        DSK 00870036
SKPLOWER DS    0H                                                   DSK 00880033
         TM    PRMOPT,FLPTASM          FLOATING POINT INSTR O.K.    DSK 00890016
         BO    TSTPRIV                 YES                          DSK 00900016
         LA    R12,SGLOP               POINT TO OP-CODE TBL             00910000
TSTOPND  DS    0H                                                       00920045
         CLI   0(R12),X'FF'            END OF TBL                       00930045
         BE    TSTPRIV                 YES                              00940000
         TM    ICLASS-INSTENT(R12),FLTPT IS IT FLOATING POINT           00950000
         BZ    FLPSTP                  NO                               00960000
         XC    0(L'SGLOP,R12),0(R12)   CLEAR ENTRY                      00970000
FLPSTP   DS    0H                                                       00980045
         LA    R12,L'SGLOP(,R12)       TO NEXT ENTRY                    00990045
         B     TSTOPND                 LOOP THRU TABLE                  01000000
TSTPRIV  DS    0H                                                       01010045
         TM    PRMOPT,PRIVASM          PRIVILEGED INSTR O.K.        DSK 01020045
         BO    MAINLINE                YES                          DSK 01030016
         LA    R12,SGLOP               POINT TO OP-CODE TBL             01040000
TTOPND   DS    0H                                                       01050045
         CLI   0(R12),X'FF'            END OF TABLE                     01060045
         BE    CKDBLS                  YES                              01070000
         TM    ICLASS-INSTENT(R12),PRIV PRIVILEGED INSTR                01080000
         BZ    PRIVSTP                 NO                               01090000
         XC    0(L'SGLOP,R12),0(R12)   YES, CLEAR ENTRY                 01100000
PRIVSTP  DS    0H                                                       01110045
         LA    R12,L'SGLOP(,R12)       TO NEXT ENTRY                    01120045
         B     TTOPND                  LOOP THRU TABLE                  01130000
CKDBLS   DS    0H                                                       01140045
         L     R12,DBLOPAD             @ 2-BYTE OP-CODE TBL             01150045
CKDBND   DS    0H                                                       01160045
         CLI   0(R12),X'FF'            END OF TBL                       01170045
         BE    MAINLINE                YES                              01180000
         TM    ICLASS-INSTENT+2(R12),PRIV PRIVILEGED OP-CODE            01190000
         BZ    DBSTP                   NO                               01200000
         XC    0(L'DBLOP,R12),0(R12)   YES, CLEAR ENTRY                 01210000
DBSTP    DS    0H                                                       01220045
         LA    R12,L'DBLOP(,R12)       TO NEXT ENTRY                    01230045
         B     CKDBND                  LOOP THRU TABLE                  01240000
******************************************************************      01250000
*                                                                *      01260000
* MAINLINE ROUTINE FOR DISASSEMBLY. EACH BYTE OF TEXT IS CHECKED *      01270000
* TO DETERMINE WHETHER IT MAY BE AN INSTRUCTION OP-CODE. IF NOT, *      01280000
* THE CONST ROUTINE IS PERFORMED TO HANDLE CONSTANT DATA. IF IT  *      01290000
* APPEARS TO BE AN OP-CODE, THE INSTR ROUTINE IS PERFORMED.      *      01300000
* WHEN TEXT IS EXHAUSTED, THIS PHASE TERMINATES.                 *      01310000
*                                                                *      01320000
******************************************************************      01330000
MAINLINE DS    0H                      MAINLINE ROUTINE                 01340036
         L     R6,LBLTBL               @ LABEL TABLE                    01350000
         USING LABELD,R6                                                01360000
         BAL   R9,LBLTRC                                                01370054
         MVC   TXTCURR,TXTSTRT         COPY TEXT START ADDR             01380000
GETCURR  DS    0H                                                       01390045
         L     R7,TXTCURR              @ CURRENT TXT BYTE               01400045
         C     R7,TXTEND               END OF TEXT                      01410000
         BNL   EOJ                     YES          FIX******           01420000
         LR    R12,R7                  COPY TEXT ADDR                   01430000
         S     R12,TXTSTRT             COMPUTE OFFSET                   01440000
         ST    R12,TXTOFST             SAVE OFFSET TO THIS BYTE         01450000
         CLC   NEXCHG,TXTOFST+1        TIME TO CHANGE BASES             01460035
         BH    CKDARNG                 NO                               01470000
         BAL   R9,NEXUSG               YES, GO DO IT                    01480000
CKDARNG  DS    0H                                                   DSK 01490038
         L     R12,DATONLY             GET DATA ONLY TBL ADDR       DSK 01500038
         USING DTA,R12                                              DSK 01510038
CKDTA    DS    0H                                                   DSK 01520038
         C     R12,DATOCUR             LAST ENTRY                   DSK 01530038
         BNL   CKLOSEQ                 END OF TABLE                 DSK 01540038
         CLC   TXTOFST+1(3),DTABGN     RANGE BEGINS LATER           DSK 01550038
         BL    CKDTANX                 YES, CHECK NEXT              DSK 01560038
         CLC   TXTOFST+1(3),DTAEND     THIS BYTE IN THE RANGE       DSK 01570038
         BNH   CONST0A                 YES, TREAT AS CONSTANT       DSK 01580038
CKDTANX  DS    0H                                                   DSK 01590038
         LA    R12,L'DTA(,R12)         PAST THIS ENTRY, STEP OVER 1 DSK 01600038
         B     CKDTA                   GO CHECK AGAIN               DSK 01610038
         DROP  R12                                                  DSK 01620038
CKLOSEQ  DS    0H                                                   DSK 01630041
         C     R6,CURRLBL              END OF TBL                   DSK 01640041
         BNL   GCKODD                  YES, NO LABEL                DSK 01650041
         CLC   TXTOFST+1(3),LBLADR     LABEL ENTRY OUT OF SEQ           01660041
         BNH   GCKODD                  NO, CONTINUE                     01670000
         BAL   R9,FORCONST             YES, FORCE ANY CONSTANT OUT      01680000
         BAL   R9,EQUDIFF              Write EQU not at current loc dsk 01690037
         NI    LBLTYP,X'BF'            We handled this label       DSK  01700037
         LA    R6,L'LABEL(,R6)         TO NEXT LABEL                    01710036
         BAL   R9,LBLTRC                                                01720054
         B     CKLOSEQ                 CONTINUE SEQ CHK                 01730000
GCKODD   DS    0H                                                       01740035
         TM    TXTCURR+3,1             ODD ADDRESS                      01750035
         BO    CONST0B                 YES, NOT INSTR               DSK 01760035
         CLC   1(3,R7),0(R7)           4 CONSEC IDENTICAL BYTES         01770000
         BE    CONST0C                 YES, NOT INSTR               DSK 01780016
         L     R1,=A(CHARTRAN)                                      DSK 01790036
         TRT   0(1,R7),0(R1)           TEST TEXT BYTE               DSK 01800036
         BNZ   CKINSTR                 NOT CHARACTER                DSK 01810016
         CLI   CONPROG,1               IS CONSTANT IN PROGRESS          01820000
         BNE   CK6                     NO                               01830000
         CLI   CONTYPE,C'C'            IS IT CHARACTER TYPE             01840000
         BE    CONST0D                 YES, ADD THIS TO CONSTANT    DSK 01850016
CK6      DS    0H                                                   DSK 01860036
         L     R1,=A(CHARTRAN)                                      DSK 01870036
         TRT   0(6,R7),0(R1)           6 CONSECUTIVE CHARACTERS         01880036
         BZ    CONST0E                 YES, NOT INSTRUCTION         DSK 01890034
CKINSTR  DS    0H                                                       01900045
         SR    R8,R8                   CLEAR WORK                       01910045
         IC    R8,0(,R7)               PICK UP TXT BYTE                 01920036
         MH    R8,SGOPLEN              TIMES TABLE LENGTH               01930000
         LA    R8,SGLOP(R8)            @ INSTR TBL ENTRY                01940036
         MVC   INSTENT,0(R8)           SAVE INSTRUCTION TBL ENTRY       01950000
         CLI   INAME,0                 IS IT AN INSTR OP-CODE           01960000
         BE    CONST0F                 NO                           DSK 01970016
         CLI   ITYPE,TWO               TWO-BYTE OP-CODE                 01980000
         BNE   INSTR                   NO                               01990000
         L     R8,DBLOPAD              YES, GET 2-BYTE TBL ADDR         02000000
DBLND    DS    0H                                                       02010045
         CLI   0(R8),X'FF'             END OF TABLE                     02020045
         BE    CONST0G                 YES, NOT INSTR               DSK 02030016
         CLC   0(2,R8),0(R7)           THIS ENTRY MATCHES TXT           02040000
         BE    GOTDBLI                 YES                              02050000
         LA    R8,L'DBLOP(,R8)         TO NEXT ENTRY                    02060036
         B     DBLND                   LOOP THRU TBL                    02070000
GOTDBLI  DS    0H                                                       02080045
         LA    R8,2(,R8)               PASS OP-CODE BYTES               02090045
         MVC   INSTENT,0(R8)           SAVE INSTR TBL ENTRY             02100000
******************************************************************      02110000
*                                                                *      02120000
* THIS ROUTINE IS ENTERED WHEN CURSORY CHECKS IN THE MAINLINE    *      02130000
* INDICATE THIS TEXT BYTE IS AN INSTRUCTION OP-CODE. FURTHER     *      02140000
* TESTING IS DONE BY THE IVERFY (NON-FLOATING POINT), OR FPVERFY *      02150000
* (FLOATING POINT) ROUTINES. BYTES PASSING THESE TESTS ARE       *      02160000
* ACCEPTED AS OP-CODES, AND ARE PASSED TO THE APPROPRIATE FORMAT *      02170000
* ROUTINES. FORMAT ROUTINES ARE ENTERED VIA A BRANCH TABLE USING *      02180000
* A BYTE IN THE INSTRUCTION OP-CODE TABLE ENTRY.                 *      02190000
*                                                                *      02200000
******************************************************************      02210000
INSTR    DS    0H                      *** INSTRUCTIONS (POSSIBLY) ***  02220036
         MVC   ILENG+1(1),INLNG        SET INSTR LENGTH                 02230000
**                                                                  DSK 02240016
         CLI   0(R7),X'45'             Is it a BAL                  DSK 02250016
         BE    ICKTBL                  Yes                          DSK 02260016
         CLI   0(R7),X'07'             Is it BRC BCR                DSK 02270016
         BE    POSSBA                  Yes                          DSK 02280016
         CLI   0(R7),X'47'             Is ita BC                    DSK 02290016
         BNE   POSSBB                  No, do normal look ahead     DSK 02300016
POSSBA   DS    0H                                                   DSK 02310016
         TM    1(R7),X'F0'             Unconditional BC or BCR      DSK 02320016
         BO    ICKTBL                  Yes, it's an instruction     DSK 02330016
POSSBB   DS    0H                                                   DSK 02340016
**                                                                  DSK 02350016
         LH    R12,ILENG               PICK UP LENGTH                   02360000
         AR    R12,R7                  ADDR OF NEXT OP CODE             02370000
         C     R12,TXTEND              END OF TEXT                  DSK 02380016
         BNL   ICKSEC                  YES, SKIP TESTING            DSK 02390016
         SR    R15,R15                 CLEAR WORK                       02400000
         IC    R15,0(,R12)             PICK UP NEXT OP-CODE             02410036
         MH    R15,SGOPLEN             TIMES TBL ENTRY LENG             02420000
         LA    R15,SGLOP(R15)          INSTR TBL ENTRY ADDR             02430036
         CLI   INAME-INSTENT(R15),0    IS IT AN OP-CODE                 02440000
         BNE   ICKSEC                  YES                              02450000
         CLI   0(R12),X'45'            IS IT BAL                    DSK 02460039
         BE    ICKTBL                  YES, CONTINUE                    02470039
         CLI   0(R12),X'07'            NO, IS IT BRCH               DSK 02480039
         BE    POSSB                   YES                              02490039
         CLI   0(R12),X'47'            IS IT BRCH                   DSK 02500039
         BNE   CONST0H                 NO, THEN THIS NOT INSTR      DSK 02510039
POSSB    DS    0H                                                       02520045
         TM    1(R12),X'F0'            IS IT UNCONDL BRCH           DSK 02530045
         BNO   CONST0I                 NO, THEN THIS NOT INSTR      DSK 02540039
         B     ICKTBL                  ACCEPT UNCOND BRCHS              02550039
ICKSEC   DS    0H                                                       02560045
         SR    R1,R1                   CLEAR WORK                       02570045
         IC    R1,INLNG-INSTENT(,R15)  GET INSTR LENGTH                 02580036
         AR    R1,R12                  ADDR OF NEXT OP CODE             02590000
         C     R1,TXTEND               END OF TEXT                  DSK 02600016
         BNL   ICKTBL                  YES, SKIP TESTING            DSK 02610016
         SR    R14,R14                 CLEAR WORK                       02620000
         IC    R14,0(,R1)              PICK UP NEXT OP-CODE             02630036
         MH    R14,SGOPLEN             TIMES TBL ENTRY LENG             02640000
         LA    R14,SGLOP(R14)          INSTR TBL ENTRY ADDR             02650036
         CLI   INAME-INSTENT(R14),0    IS IT AN OP-CODE                 02660000
         BNE   ICKTBL                  YES                              02670039
         CLI   0(R12),X'45'            IS IT BAL                        02680039
         BE    ICKTBL                  YES, CONTINUE                    02690039
         CLI   0(R12),X'07'            NO, IS IT BRCH                   02700039
         BE    POSSB2                  YES                              02710039
         CLI   0(R12),X'47'            IS IT BRCH                       02720039
         BNE   CONST0J                 NO, THEN THIS NOT INSTR          02730039
POSSB2   DS    0H                                                       02740045
         TM    1(R12),X'F0'            IS IT UNCONDL BRCH               02750045
         BNO   CONST0K                 NO, THEN THIS NOT INSTR          02760039
ICKTBL   DS    0H                                                       02770045
         LH    R12,ILENG               GET INSTR LENGTH                 02780045
         AR    R12,R7                  @ NEXT TEXT LOC                  02790000
         BCTR  R12,0                   BACK UP 1                        02800039
         S     R12,TXTSTRT             RELATIVE TO CSECT START          02810052
         CLM   R12,7,LBLADR            LBL TBL ADDR HERE                02820000
         BL    NOILBL                  NO                               02830000
         CLC   TXTOFST+1(3),LBLADR     LABEL AT INSTR START             02840035
         BE    SETLBL                                               dsk 02850037
         CLI   LBLTYP,LBLTYPL          IS IT A LABEL ONLY           dsk 02860048
         BNE   NOTINST                 NO, MUST BE CONSTANT      FIX*** 02870037
         BAL   R9,EQUDIFF              Write EQU not at current loc dsk 02880037
         NI    LBLTYP,X'BF'            We handled this label        dsk 02890037
         LA    R6,L'LABEL(,R6)         TO NEXT ENTRY                dsk 02900037
         BAL   R9,LBLTRC                                                02910054
         CLI   CONPROG,1               CONSTANT IN PROGRESS             02920000
         BNE   CKLBLNG                 NO                               02930000
         BAL   R9,FORCONST             YES, FORCE IT OUT                02940000
CKLBLNG  DS    0H                                                       02950045
         CLM   R12,7,LBLADR            Label addr before instr end      02960052
         BL    ICKTBL                  NO                               02970052
         CLC   LBLLEN,INLNG            LENGTHS SAME                     02980045
         BE    SETLBL                  YES                              02990000
         CLI   LBLLEN,0                DON'T CARE LENGTH           DSK1 03000028
         BE    SETLBL                  YES                         DSK1 03010037
         BAL   R9,EQUSTMT              NO, BUILD EQU STATEMENT          03020000
         NI    LBLTYP,X'BF'            We handled this label       DSK  03030025
         LA    R6,L'LABEL(,R6)         TO NEXT LABEL TBL ENTRY          03040037
         BAL   R9,LBLTRC                                                03050054
MORLBLS  DS    0H                                                       03060037
         CLM   R12,7,LBLADR            Label addr before instr end      03070052
         BL    ICKTBL                  NO                               03080052
         BAL   R9,EQUSTMT              GO BUILD EQU STATEMENT           03090000
         NI    LBLTYP,X'BF'            We handled this label       DSK  03100025
         LA    R6,L'LABEL(,R6)         TO NEXT ENTRY                    03110036
         BAL   R9,LBLTRC                                                03120054
         B     MORLBLS                 GO CHECK NEXT LABEL              03130037
SETLBL   DS    0H                                                   dsk 03140037
         CLI   CONPROG,1               CONSTANT IN PROGRESS         dsk 03150039
         BNE   SETLBL1                 NO                           dsk 03160039
         BAL   R9,FORCONST             YES, FORCE IT OUT            dsk 03170039
SETLBL1  DS    0H                                                   dsk 03180039
         MVC   NAME,LBLNAME            LABEL ENTRY NAME TO INSTR    dsk 03190037
         NI    LBLTYP,X'BF'            We handled this label        dsk 03200037
         LA    R6,L'LABEL(,R6)         TO NEXT ENTRY                dsk 03210037
         BAL   R9,LBLTRC                                                03220054
         B     MVMNE                                                    03230039
NOILBL   DS    0H                                                       03240045
         CLI   CONPROG,1               CONSTANT IN PROGRESS             03250045
         BNE   MVMNE                   NO                               03260000
         BAL   R9,FORCONST             YES, FORCE IT OUT                03270000
MVMNE    DS    0H                                                       03280045
         MVC   MNEMONIC,0(R8)          SET INSTR MNEMONIC               03290045
         MVC   OFFSET,TXTOFST+1        SET OFFSET                       03300035
         MVC   INSTYP,5(R8)            SET INSTR TYPE                   03310000
         MVI   TYPE,X'0D'              SHOW IT IS AN INSTRUCTION        03320000
         MVC   LEN,ILENG+1             SHOW LENGTH                      03330000
         MVC   TEXT(6),0(R7)           MOVE ACTUAL TEXT                 03340000
OPNDFMT  DS    0H                                                       03350045
         TM    ICLASS,FLTPT            FLOATING POINT OP-CODE           03360045
         BO    FPVERFY                 YES, GO VERIFY                   03370000
         CLI   IEDT,0                  ANY EDIT REQUIRED                03380000
         BE    PFMFMT                  NO                               03390000
         B     IVERFY                  YES, GO EDIT                     03400000
PFMFMT   DS    0H                                                       03410045
         SR    R1,R1                   CLEAR WORK                       03420045
         IC    R1,INSTYP               GET INSTRUCTION TYPE             03430000
         L     R9,OPND9                GET FORMAT ROUTINE RETURN ADDR   03440000
         B     *+4(R1)                 TO APPROPRIATE FORMATTING ROUTIN 03450000
         B     RROPND                  TYPE=0, RR                       03460000
         B     RXOPND                  TYPE=4, RX                       03470000
         B     SOPND                   TYPE=8, S                        03480000
         B     SIOPND                  TYPE=C, SI                       03490000
         B     RSOPND                  TYPE=10, RS                      03500000
         B     SS1OPND                 TYPE=14, 1-LENGTH SS             03510000
         B     SS2OPND                 TYPE=18, 2-LENGTH SS             03520000
         B     SOPND                   TYPE=1C, 2-BYTE OP-CODES         03530000
         B     BCOPND                  TYPE=20, CONDITIONAL BRANCH      03540000
         B     SVCOPND                 TYPE=24, SVC                     03550000
OPNDRTN  B     INSTOUT                 NORMAL OPERAND FORMAT RETURN     03560000
         MVC   CONNAME,NAME            ANY NAME TO CONSTANT AREA        03570000
         B     CONST0L                 ERROR INSTRUCTION, TREAT AS CONS 03580035
NOTINST  DS    0H                                                       03590045
         CLC   NAME,BLANX              IS NAME FILLED IN?        FIX*** 03600045
         BE    CONST0M                                           FIX*** 03610035
         SH    R6,LBLLGTH              BACK UP                   FIX*** 03620000
         B     CONST0N                                           FIX*** 03630035
INSTOUT  DS    0H                                                   DSK 03640016
         BAL   R9,TXTFMT               FORMAT HEX DATA              DSK 03650016
         BAL   R9,WRTOUT               WRITE INSTRUCTION RECORD     DSK 03660016
         BAL   R9,PRINT                GO PRINT IT                      03670000
         AH    R7,ILENG                STEP TO NEXT TEXT BYTE           03680000
         ST    R7,TXTCURR              SAVE NEXT ADDR                   03690000
         MVC   CCTYPE,ICCSET           SHOW COND CODE SET TYPE          03700000
         B     GETCURR                 CONTINUE TXT PROCESSING          03710000
******************************************************************      03720000
*                                                                *      03730000
* THIS ROUTINE IS ENTERED FROM THE INSTR ROUTINE FOR NON FLOATING*      03740000
* POINT INSTRUCTIONS. VARIOUS EDITS ARE PERFORMED TO INSURE THE  *      03750000
* INPUT TEXT BYTE IS AN OP-CODE. IF IT IS, RETURN IS TO LABEL    *      03760000
* PFMFMT, OTHERWISE THE CONST ROUTINE IS PERFORMED.              *      03770000
*                                                                *      03780000
******************************************************************      03790000
IVERFY   DS    0H                      *** VERIFY POSSIBLE INSTRUCTION  03800036
         TM    IEDT,EPR                EVEN-ODD REG PAIR                03810000
         BZ    IVE2                    NO                               03820000
         TM    1(R7),X'10'             R1 IS ODD                        03830000
         BO    CONST0O                 YES, NOT INSTR                   03840035
         CLI   0(R7),X'0E'             IS IT MVCL                       03850000
         BE    IVTRG2                  YES                              03860000
         CLI   0(R7),X'0F'             IS IT CLCL                       03870000
         BNE   IVE2                    NO                               03880000
IVTRG2   DS    0H                                                       03890045
         TM    1(R7),X'01'             R2 IS ODD                        03900045
         BO    CONST0P                 YES, NOT INSTR                   03910035
         SR    R1,R1                   CLEAR WORK                       03920000
         SR    R2,R2                   CLEAR WORK                       03930000
         IC    R1,1(,R7)               GET R1R2                         03940036
         SRL   R1,4                    SHIFT OUT R2                     03950000
         PACK  DBLWD(1),1(1,R7)        FLIP R1R2 BYTE                   03960000
         IC    R2,DBLWD                PICK UP R2R1                     03970000
         SRL   R2,4                    SHIFT OUT R1                     03980000
         CR    R1,R2                   R1=R2                            03990000
         BE    CONST0Q                 YES, NOT INSTR                   04000035
         B     PFMFMT                  NO, GOOD INSTR                   04010000
IVE2     DS    0H                                                       04020045
         TM    IEDT,E2                 HALFWORD STORAGE ALIGNMENT       04030045
         BZ    IVE4                    NO                               04040000
         TM    3(R7),X'01'             DISPL IS ODD                     04050000
         BZ    IVES2                   NO, O.K.                         04060000
         TM    2(R7),X'F0'             BASE REG = 0                     04070000
         BNZ   IVES2                   NO, CONTINUE                     04080000
         CLI   0(R7),X'44'             EX OP CODE                       04090000
         BE    CONST0R                 YES, NOT INSTR                   04100035
         CLI   0(R7),X'47'             BC OP CODE                       04110000
         BE    CONST0S                 YES, NOT INSTR                   04120035
         CLI   ITYPE,RS                RS INSTRUCTION                   04130000
         BE    CONST0T                 YES, NOT INSTR                   04140035
         TM    1(R7),X'0F'             INDEX REG IS 0                   04150000
         BZ    CONST0U                 YES, NOT INSTR                   04160035
         B     IVES2                   CONTINUE                         04170000
IVE4     DS    0H                                                       04180045
         TM    IEDT,E4                 2ND OPND ON FULLWORD BOUND       04190045
         BZ    IVE8                    NO                               04200000
         TM    3(R7),X'03'             DISPL DIV BY 4                   04210000
         BZ    IVES2                   YES, O.K.                        04220000
         TM    2(R7),X'F0'             BASE REG = 0                     04230000
         BNZ   IVES2                   NO, CONTINUE                     04240000
         CLI   ITYPE,RS                RS INSTRUCTION OP CODE           04250000
         BE    CONST0V                 YES, NOT INSTR                   04260035
         TM    1(R7),X'0F'             INDEX REG = 0                    04270000
         BZ    CONST0W                 YES, NOT INSTR                   04280035
         B     IVES2                   NO, CONTINUE                     04290000
IVE8     DS    0H                                                       04300045
         TM    IEDT,E8                 2ND OPND ON DBLWD BOUND          04310045
         BZ    IVES2                   NO                               04320000
         TM    3(R7),X'07'             DISPL DIV BY 8                   04330000
         BZ    IVES2                   YES, O.K.                        04340000
         TM    2(R7),X'F0'             BASE REG = 0                     04350000
         BNZ   IVES2                   NO                               04360000
         TM    1(R7),X'0F'             INDEX REG = 0                    04370000
         BZ    CONST0X                 YES, NOT INSTR                   04380035
IVES2    DS    0H                                                       04390045
         TM    PRMOPT,PRIVASM          PRIVILEGED INSTR O.K.        DSK 04400045
         BO    PFMFMT                  YES                          DSK 04410016
         TM    IEDT,S2                 OPND2 MUST HAVE BASE             04420000
         BZ    IVES1                   NO                               04430000
         TM    2(R7),X'F0'             BASE REG = 0                     04440000
         BNZ   PFMFMT                  NO, O.K.                         04450000
         CLI   ITYPE,RS                RS INSTRUCTION                   04460000
         BE    CONST0Y                 YES, NOT INSTR                   04470035
         CLI   0(R7),X'92'             IS IT MVI OP CODE                04480000
         BE    CONST0Z                 YES, NOT INSTR                   04490035
         TM    1(R7),X'0F'             INDEX REG = 0                    04500000
         BZ    CONST00                 YES, NOT INSTR                   04510035
         B     PFMFMT                  NO, GOOD INSTR                   04520000
IVES1    DS    0H                                                       04530045
         TM    IEDT,S1                 1ST OPND MUST HAVE BASE          04540045
         BZ    PFMFMT                  NO, CONTINUE                     04550000
         TM    2(R7),X'F0'             1ST OPND HAS BASE                04560000
         BZ    CONST01                 NO, NOT INSTR                    04570035
         B     PFMFMT                  YES, INSTR O.K.                  04580000
******************************************************************      04590000
*                                                                *      04600000
* THIS ROUTINE IS ENTERED FROM THE INSTR ROUTINE FOR FLOATING    *      04610000
* POINT INSTRUCTIONS. VARIOUS EDITS ARE PERFORMED TO INSURE THE  *      04620000
* INPUT TEXT BYTE IS AN OP-CODE. IF IT IS, RETURN IS TO LABEL    *      04630000
* PFMFMT, OTHERWISE THE CONST ROUTINE IS PERFORMED.              *      04640000
*                                                                *      04650000
******************************************************************      04660000
FPVERFY  DS    0H                      *** VALIDATE FLOATING POINT OP-C 04670036
         TM    1(R7),X'90'             R1 IS 0, 2, 4, OR 6              04680000
         BNZ   CONST02                 NO, NOT INSTR                    04690035
         CLI   0(R7),X'27'             MXDR OP-CODE                     04700000
         BE    FPR1EXT                 YES                              04710000
         CLI   0(R7),X'67'             MXD OP-CODE                      04720000
         BNE   FPCKTYP                 NO                               04730000
FPR1EXT  DS    0H                                                       04740045
         TM    1(R7),X'B0'             R1 IS 0 OR 4                     04750045
         BNZ   CONST03                 NO, NOT INSTR                    04760035
FPCKTYP  DS    0H                                                       04770045
         CLI   ITYPE,RR                RR TYPE INSTRUCTION              04780045
         BNE   FPRXVER                 NO                               04790000
         TM    1(R7),X'09'             R2 IS 0, 2, 4, 6                 04800000
         BNZ   CONST04                 NO, NOT INSTR                    04810035
         CLI   0(R7),X'25'             LRDR OP CODE                     04820000
         BE    FPR2EXT                 YES                              04830000
         CLI   0(R7),X'37'             SXR OP-CODE                      04840000
         BE    FPR2EXT                 YES                              04850000
         CLI   0(R7),X'26'             MXR OP-CODE                      04860000
         BE    FPR2EXT                 YES                              04870000
         CLI   0(R7),X'36'             AXR OP-CODE                      04880000
         BNE   PFMFMT                  NO, GOOD INSTR                   04890000
FPR2EXT  DS    0H                                                       04900045
         TM    1(R7),X'0B'             R2 IS 0 OR 4                     04910045
         BZ    PFMFMT                  YES, GOOD INSTR                  04920000
         B     CONST05                 NO, NOT INSTR                    04930035
FPRXVER  DS    0H                                                       04940045
         TM    PRMOPT,PRIVASM          PRIVILEGED INSTRUCTIONS O.K. DSK 04950045
         BO    FPALIGN                 YES                          DSK 04960016
         TM    2(R7),X'F0'             ANT BASE REG                     04970000
         BNZ   FPALIGN                 YES                              04980000
         TM    1(R7),X'0F'             ANY INDEX REG                    04990000
         BZ    CONST06                 NO, NOT INSTR                    05000035
FPALIGN  DS    0H                                                       05010045
         TM    2(R7),X'F0'             ANY BASE REG                     05020045
         BNZ   PFMFMT                  YES, ACCEPT INSTR                05030000
         TM    1(R7),X'0F'             ANY INDEX REG                    05040000
         BNZ   PFMFMT                  YES, ACCEPT INSTR                05050000
         TM    3(R7),X'03'             DISPL DIV BY 4                   05060000
         BNZ   CONST07                 NO, NOT INSTR                    05070035
         TM    ICLASS,FLSHT            SHORT PRECISION                  05080000
         BO    PFMFMT                  YES, ACCEPT INSTRUCTION          05090000
         TM    3(R7),X'07'             DISPL DIV BY 8                   05100000
         BZ    PFMFMT                  YES, ACCEPT INSTR                05110000
         B     CONST08                 NO, NOT INSTR                    05120035
******************************************************************      05130000
*                                                                *      05140000
* THIS ROUTINE IS ENTERED FROM VARIOUS OTHER ROUTINES WHEN THE   *      05150000
* CURRENT TEXT BYTE IS DETERMINED NOT TO BE AN INSTRUCTION OP    *      05160000
* CODE. A CONSTANT AREA IS BUILT TO CONTAIN THE CONSTANT, IT'S   *      05170000
* DATA TYPE, SYMBOL TO BE USED FOR ADCONS, LABEL TO BE USED, IF  *      05180000
* ANY, ETC. THE CONSTANT IS BUILT BYTE BY BYTE, AND IS TERMINATED*      05190000
* FOR OUTPUT BY THE FORCONST ROUTINE. THIS ROUTINE DETECTS END OF*      05200000
* CONSTANT WHEN THE CONSTANT IN PROGRESS EXCEEDS 2 BYTES FOR A   *      05210000
* HALFWORD, 4 BYTES FOR A FULLWORD, OR 8 BYTES AS A MAXIMUM. IT  *      05220000
* IS ALSO TERMINATED WHEN A CHANGE IN DATA TYPE OCCURS.          *      05230000
*                                                                *      05240000
******************************************************************      05250000
CONST0A  DS    0H                      Defined via DATA             DSK 05260035
*dsk     LA    R0,C'A'                                              DSK 05270053
*dsk     B     CONSTTRC                                             DSK 05280053
CONST0B  DS    0H                      Odd address                  DSK 05290035
*dsk     LA    R0,C'B'                                              DSK 05300053
*dsk     B     CONSTTRC                                             DSK 05310053
CONST0C  DS    0H                      All 4 bytes equal            DSK 05320035
*dsk     LA    R0,C'C'                                              DSK 05330053
*dsk     B     CONSTTRC                                             DSK 05340053
CONST0D  DS    0H                      Character constant           DSK 05350035
*dsk     LA    R0,C'D'                                              DSK 05360053
*dsk     B     CONSTTRC                                             DSK 05370053
CONST0E  DS    0H                      Constant 6 bytes same        DSK 05380035
*dsk     LA    R0,C'E'                                              DSK 05390053
*dsk     B     CONSTTRC                                             DSK 05400053
CONST0F  DS    0H                      Not valid opcode             DSK 05410035
*dsk     LA    R0,C'F'                                              DSK 05420053
*dsk     B     CONSTTRC                                             DSK 05430053
CONST0G  DS    0H                      Not valid opcode             DSK 05440035
*dsk     LA    R0,C'G'                                              DSK 05450053
*dsk     B     CONSTTRC                                             DSK 05460053
CONST0H  DS    0H                      Not valid opcode             DSK 05470035
*dsk     LA    R0,C'H'                                              DSK 05480053
*dsk     B     CONSTTRC                                             DSK 05490053
CONST0I  DS    0H                      Not valid opcode             DSK 05500035
*dsk     LA    R0,C'I'                                              DSK 05510053
*dsk     B     CONSTTRC                                             DSK 05520053
CONST0J  DS    0H                                                   DSK 05530035
*dsk     LA    R0,C'J'                                              DSK 05540053
*dsk     B     CONSTTRC                                             DSK 05550053
CONST0K  DS    0H                                                   DSK 05560035
*dsk     LA    R0,C'K'                                              DSK 05570053
*dsk     B     CONSTTRC                                             DSK 05580053
CONST0L  DS    0H                                                   DSK 05590035
*dsk     LA    R0,C'L'                                              DSK 05600053
*dsk     B     CONSTTRC                                             DSK 05610053
CONST0M  DS    0H                                                   DSK 05620035
*dsk     LA    R0,C'M'                                              DSK 05630053
*dsk     B     CONSTTRC                                             DSK 05640053
CONST0N  DS    0H                                                   DSK 05650035
*dsk     LA    R0,C'N'                                              DSK 05660053
*dsk     B     CONSTTRC                                             DSK 05670053
CONST0O  DS    0H                                                   DSK 05680035
*dsk     LA    R0,C'O'                                              DSK 05690053
*dsk     B     CONSTTRC                                             DSK 05700053
CONST0P  DS    0H                                                   DSK 05710035
*dsk     LA    R0,C'P'                                              DSK 05720053
*dsk     B     CONSTTRC                                             DSK 05730053
CONST0Q  DS    0H                                                   DSK 05740035
*dsk     LA    R0,C'Q'                                              DSK 05750053
*dsk     B     CONSTTRC                                             DSK 05760053
CONST0R  DS    0H                                                   DSK 05770035
*dsk     LA    R0,C'R'                                              DSK 05780053
*dsk     B     CONSTTRC                                             DSK 05790053
CONST0S  DS    0H                                                   DSK 05800035
*dsk     LA    R0,C'S'                                              DSK 05810053
*dsk     B     CONSTTRC                                             DSK 05820053
CONST0T  DS    0H                                                   DSK 05830035
*dsk     LA    R0,C'T'                                              DSK 05840053
*dsk     B     CONSTTRC                                             DSK 05850053
CONST0U  DS    0H                                                   DSK 05860035
*dsk     LA    R0,C'U'                                              DSK 05870053
*dsk     B     CONSTTRC                                             DSK 05880053
CONST0V  DS    0H                                                   DSK 05890035
*dsk     LA    R0,C'V'                                              DSK 05900053
*dsk     B     CONSTTRC                                             DSK 05910053
CONST0W  DS    0H                                                   DSK 05920035
*dsk     LA    R0,C'W'                                              DSK 05930053
*dsk     B     CONSTTRC                                             DSK 05940053
CONST0X  DS    0H                                                   DSK 05950035
*dsk     LA    R0,C'X'                                              DSK 05960053
*dsk     B     CONSTTRC                                             DSK 05970053
CONST0Y  DS    0H                                                   DSK 05980035
*dsk     LA    R0,C'Y'                                              DSK 05990053
*dsk     B     CONSTTRC                                             DSK 06000053
CONST0Z  DS    0H                                                   DSK 06010035
*dsk     LA    R0,C'Z'                                              DSK 06020053
*dsk     B     CONSTTRC                                             DSK 06030053
CONST00  DS    0H                                                   DSK 06040035
*dsk     LA    R0,C'0'                                              DSK 06050053
*dsk     B     CONSTTRC                                             DSK 06060053
CONST01  DS    0H                                                   DSK 06070035
*dsk     LA    R0,C'1'                                              DSK 06080053
*dsk     B     CONSTTRC                                             DSK 06090053
CONST02  DS    0H                                                   DSK 06100035
*dsk     LA    R0,C'2'                                              DSK 06110053
*dsk     B     CONSTTRC                                             DSK 06120053
CONST03  DS    0H                                                   DSK 06130035
*dsk     LA    R0,C'3'                                              DSK 06140053
*dsk     B     CONSTTRC                                             DSK 06150053
CONST04  DS    0H                                                   DSK 06160035
*dsk     LA    R0,C'4'                                              DSK 06170053
*dsk     B     CONSTTRC                                             DSK 06180053
CONST05  DS    0H                                                   DSK 06190035
*dsk     LA    R0,C'5'                                              DSK 06200053
*dsk     B     CONSTTRC                                             DSK 06210053
CONST06  DS    0H                                                   DSK 06220035
*dsk     LA    R0,C'6'                                              DSK 06230053
*dsk     B     CONSTTRC                                             DSK 06240053
CONST07  DS    0H                                                   DSK 06250035
*dsk     LA    R0,C'7'                                              DSK 06260053
*dsk     B     CONSTTRC                                             DSK 06270053
CONST08  DS    0H                                                   DSK 06280035
*dsk     LA    R0,C'8'                                              DSK 06290053
*dsk     B     CONSTTRC                                             DSK 06300053
CONSTTRC DS    0H                                                   DSK 06310035
*dsk     MVC   CONTRC(L'CONTRC-1),CONTRC+1                          DSK 06320053
*dsk     STC   R0,CONTRC+L'CONTRC-1                                 DSK 06330053
CONST    DS    0H                      *** PROCESS CONSTANTS ***    DSK 06340016
         MVC   WORKREC,BLANX           CLEAR WORK RECORD AREA           06350000
         CLI   CONPROG,1               CONSTANT IN PROGRESS             06360000
         BNE   CCNEW                   NO                               06370000
         CLC   TXTOFST+1(3),LBLADR     LABEL ENTRY HAS THIS OFFSET      06380035
         BNE   CGETYP                  NO                               06390000
CSTNEW   DS    0H                                                       06400045
         BAL   R9,FORCONST             FORCE IT OUT                     06410045
         B     CCNEW                   GO START A NEW ONE               06420000
CGETYP   DS    0H                                                   DSK 06430036
         L     R1,=A(CHARTRAN)                                      DSK 06440036
         TRT   0(1,R7),0(R1)           CHECK DATA TYPE OF BYTE      dsk 06450045
         BNZ   CHEX                    IT'S HEX                         06460000
         MVI   CCKTYP+1,C'C'           SET TYPE IN COMPARE              06470000
         B     CCKTYP                  GO COMPARE                       06480000
CHEX     DS    0H                                                       06490045
         MVI   CCKTYP+1,C'X'           SET TYPE IN COMPARE              06500045
CCKTYP   DS    0H                                                       06510045
         CLI   CONTYPE,C' '            TYPE IN PROG SAME AS THIS BYTE   06520045
         BNE   CSTNEW                  NO                               06530000
CUPDCON  DS    0H                                                  DSK1 06540028
         SR    R11,R11                                             DSK1 06550028
         ICM   R11,3,CONLEN            GET CURRENT LENGTH          DSK1 06560028
         LA    R11,1(,R11)             ADD 1                            06570036
         STH   R11,CONLEN              UPDATE LENGTH                    06580000
         L     R11,CONLOC              GET CURRENT LOC IN CONST DATA    06590000
         MVC   0(1,R11),0(R7)          MOVE BYTE TO DATA                06600000
         LA    R11,1(,R11)             STEP OVER ONE BYTE               06610036
         ST    R11,CONLOC              SAVE UPDATED DATA ADDR           06620000
         CLI   CONTYPE,C'C'            CHARACTER CONSTANT               06630000
         BE    CCK50                   YES                              06640002
         TM    CONOFST+3,1             OFFSET IS ODD                    06650000
         BO    CCFIN1                  YES                              06660000
         TM    CONOFST+3,2             HALFWORD OFFSET                  06670000
         BZ    CCFWD                   NO                               06680000
         CLC   CONLEN,=H'1'            HALFWORD, IS LENGTH = 1     DSK1 06690052
         BE    CCXIT1                  YES                              06700000
         B     CCFIN1                  NO                               06710000
CCFWD    DS    0H                                                  DSK1 06720028
         CLC   CONLEN,=H'4'            NO, IS HEX CONST 4 BYTES    DSK1 06730052
         BL    CCXIT1                  NOT YET                          06740000
CCFIN1   DS    0H                                                       06750045
         BAL   R9,FORCONST             MAX LENG, FORCE IT OUT           06760045
         B     CCXIT1                  FINISH                           06770000
CCK50    DS    0H                                                  DSK1 06780028
         CLC   CONLEN,=H'50'           CHAR CONSTANT 50 BYTES      DSK1 06790028
         BNL   CCFIN1                  YES                              06800000
CCXIT1   DS    0H                                                       06810045
         LA    R7,1(,R7)               STEP OVER 1 BYTE IN TEXT         06820045
         ST    R7,TXTCURR              UPDATE TEXT ADDR                 06830000
         B     GETCURR                 CONTINUE TEXT PROCESSING         06840000
CCNEW    DS    0H                                                       06850045
         MVI   CONPROG,1               SHOW CONSTANT IN PROGRESS        06860045
         MVC   CONOFST,TXTOFST         SET OFFSET TO 1ST BYTE           06870000
         MVC   CONNAME,BLANX           CLEAR NAME                       06880000
         XC    CONDATA,CONDATA         CLEAR DATA AREA                  06890000
         MVC   CONSYM,BLANX            CLEAR SYMBOL NAME                06900000
         XC    CONLEN,CONLEN           CLEAR LENGTH                DSK1 06910028
         LA    R11,CONDATA             GET 1ST DATA BYTE ADDR           06920000
         ST    R11,CONLOC              SET STARTING ADDRESS OF DATA     06930000
         CLC   TXTOFST+1(3),LBLADR     LABEL AT THIS OFFSET             06940035
         BE    CLBLD                   YES                              06950000
TRTYPE   DS    0H                                                   DSK 06960036
         L     R1,=A(CHARTRAN)                                      DSK 06970036
         TRT   0(1,R7),0(R1)           CHECK DATA TYPE OF BYTE          06980043
         BNZ   CCSHX                   IT'S HEX                         06990000
         MVI   CONTYPE,C'C'            IT'S CHAR, SO INDICATE           07000000
         B     CUPDCON                 GO COMPLETE                      07010000
CCSHX    DS    0H                                                       07020045
         MVI   CONTYPE,C'X'            IT'S HEX, SO INDICATE            07030045
         B     CUPDCON                 GO COMPLETE                      07040000
CLBLD    DS    0H                                                       07050045
         CLI   LBLTYP,LBLTYPL          IS IT A LABEL ONLY               07060048
         BNE   CDATACON                NO                               07070044
         BAL   R9,EQUSTMT              GO BUILD EQU STATEMENT           07091054
         NI    LBLTYP,X'BF'            We handled this label            07100054
         LA    R6,L'LABEL(,R6)         TO NEXT LABELENTRY               07110054
         BAL   R9,LBLTRC                                                07120054
         CLC   TXTOFST+1(3),LBLADR     Next label at same addr          07130054
         BNE   TRTYPE                  NO                               07140044
         CLI   LBLTYP,LBLTYPL          Next another label only          07150054
         BNE   CDATACON                NO                               07160044
         BAL   R9,EQUSTMT              GO BUILD EQU STATEMENT           07200054
         NI    LBLTYP,X'BF'            We handled this label            07210054
         LA    R6,L'LABEL(,R6)         TO NEXT LABELENTRY               07220044
         BAL   R9,LBLTRC                                                07230054
         B     CCNEW                   GO TO NEXT LABEL                 07260044
CDATACON DS    0H                                                       07270045
         MVC   CONTYPE,LBLTYP          TYPE TO CONSTANT AREA            07280045
         SR    R1,R1                   CLEAR WORK                       07290044
         IC    R1,LBLLEN               PICK UP CONSTNT LENGTH           07300044
         STH   R1,CONLEN               SAVE CONSTANT LENGTH             07310044
         CLI   LBLLEN,0                                                 07320054
         BE    SKPMCON                                                  07330054
         BCTR  R1,0                    COMPUTE CONSTANT LEN CODE        07340054
         STC   R1,MCD+1                SET MOVE LENGTH CODE             07350044
MCD      MVC   CONDATA,0(R7)           MOVE DATA TO RECORD              07360044
SKPMCON  DS    0H                                                       07370054
         MVC   CONSYM,LBLNAME          SYMBOL TO CONSTANT AREA          07380044
         SR    R11,R11                 CLEAR WORK REG                   07390044
         IC    R11,LBLLEN              PICK UP LENGTH                   07400044
         AR    R7,R11                  STEP PAST TEXT                   07410044
         ST    R7,TXTCURR              UPDATE TEXT ADDRESS              07420044
         BAL   R9,FORCONST             FORCE CONSTANT OUT               07430044
         NI    LBLTYP,X'BF'            We handled this label            07440054
         LA    R6,L'LABEL(,R6)         STEP TO NEXT LABEL ENTRY         07450044
         BAL   R9,LBLTRC                                                07460054
         B     GETCURR                 CONTINUE TEXT PROCESS            07470044
******************************************************************      07480000
*                                                                *      07490000
* THIS ROUTINE IS ENTERED BY VARIOUS ROUTINES WHEN IT IS         *      07500000
* NECESSARY TO WRITE THE CONSTANT CURRENTLY IN PROGRESS, AND     *      07510000
* CLEAR FIELDS FOR THE NEXT CONSTANT TO BE CREATED.              *      07520000
*                                                                *      07530000
******************************************************************      07540000
FORCONST DS    0H                      *** FORCE OUT CONSTANT IN PROGRE 07550035
         ST    R9,FC9                  SAVE RETURN ADDR                 07560000
         TM    PRMOPT,DBGCONST         DEBUG(CONST)                 DSK 07570016
         BZ    NODBGX                  No                           DSK 07580016
         CLC   WORKREC+46(6),BLANX     IF LITERAL/COMMENTS HERE     DSK 07590035
         BNE   NODBGX                  Skip reason                  DSK 07600035
*dsk     MVC   WORKREC+44(4),=C'RSN='                               DSK 07610053
*dsk     MVC   WORKREC+48(4),CONTRC    Reason for constant          DSK 07620053
*dsk     MVC   CONTRC,BLANX                                         DSK 07630053
NODBGX   DS    0H                                                   DSK 07640016
         CLC   CONNAME,BLANX           ANY LABEL NAME SET UP            07650000
         BE    CKCNPRG                 NO, CONTINUE                     07660000
         CLC   CONLLEN,CONLEN+1        LENGTHS SAME                     07670000
         BE    CKCNPRG                 YES, CONTINUE                    07680000
         MVC   CONADR,CONOFST+1        Just for debugging               07690045
         L     R0,FC9                                                   07700051
         ST    R6,FC6                  SAVE LABEL TABLE ADDR            07710000
         LA    R6,CONPSLBL             @ PSEUDO LABEL ENTRY             07720000
         BAL   R9,EQUSTMT              GO BUILD EQU STATEMENT           07730000
         MVC   CONNAME,BLANX           CLEAR STATEMENT LABEL FIELD      07740000
         L     R6,FC6                  RESTORE LABEL TABLE POINTER      07750000
CKCNPRG  DS    0H                                                       07760045
         CLI   CONPROG,1               CONSTANT IN PROGRESS             07770045
         BNE   FCCLR                   NO                               07780000
         OC    CONLEN,CONLEN           ANY DATA LENGTH             DSK1 07790028
         BE    FCCLR                   NO                               07800000
         XC    TEXT,TEXT               CLEAR TEXT FIELD                 07810000
         MVC   MNEMONIC(2),=C'DC'      SET MNEMONIC                     07820000
         MVC   OPNDS(1),CONTYPE        SET TYPE                         07830000
         MVI   OPNDS+1,C''''           OPERAND DELIMITER                07840000
         MVC   NAME,CONNAME            NAME TO RECORD                   07850000
         MVC   OFFSET,CONOFST+1        OFFSET TO RECORD                 07860000
         MVI   INSTYP,0                NOT AN INSTRUCTION               07870000
         MVI   TYPE,2                  NON-ADDRESS CONSTANT             07880000
         MVC   LEN,CONLEN+1            DATA LENGTH                      07890000
         SR    R11,R11                                             DSK1 07900028
         ICM   R11,3,CONLEN            DATA LENGTH                 DSK1 07910028
         BCTR  R11,0                   DATA LENGTH CODE            DSK1 07920028
         STC   R11,FMCON+1             MOVE LENGTH TO MVC               07930000
FMCON    MVC   TEXT,CONDATA            DATA TO RECORD                   07940000
         CLI   CONTYPE,C'C'            CHARACTER TYPE                   07950000
         BE    FCHAR                   YES                              07960000
         CLI   CONTYPE,C'X'            HEX TYPE                         07970000
         BNE   FSYMBOL                 NO                               07980000
         B     FHEX                    SKIP HALF/FULLWORD         *dsk  07990045
*dsk     TM    CONOFST+3,1             OFFSET TO CONSTANT IS ODD        08000045
*dsk     BO    FHEX                    YES                              08010045
*dsk     TM    CONLEN+1,1              LENGTH IS ODD                    08020045
*dsk     BO    FHEX                    YES                              08030045
*dsk     TM    CONOFST+3,2             OFFSET DIVISIBLE BY 4            08040045
*dsk     BO    FHWD                    NO                               08050045
*dsk     CLI   CONLEN+1,4              IS IT 4-BYTES                    08060045
*dsk     BNE   FHWD                    NO, JUST HALFWORD                08070045
*dsk     CLC   CONDATA(4),XZROS        CONSTANT IS ALL ZEROS            08080045
*dsk     BNE   FFCKNEG                 NO                               08090045
*dsk     MVC   OPNDS(4),=C'F''0'''     BUILD OPERANDS                   08100045
*dsk     B     FCWRT                   CONTINUE                         08110045
FFCKNEG  DS    0H                                                       08120045
         ICM   R11,15,CONDATA          GET DATA                         08130045
         BM    FHEX                    NEG, TREAT AS HEX                08140000
         C     R11,=F'99999'           VALUE EXCEEDS 99,999             08150000
         BH    FHEX                    YES, TREAT AS HEX                08160000
         MVC   OPNDS(2),=C'F'''        OPERAND DATA TYPE IS F           08170000
         CVD   R11,DBLWD               CONVERT VALUE TO PACKED          08180000
         UNPK  OPNDS+2(5),DBLWD+5(3)   UNPACK INTO OPERAND              08190000
         OI    OPNDS+6,C'0'            SET SIGN = F                     08200000
         MVI   OPNDS+7,C''''           ENDING QUOTE                     08210000
         B     FCWRT                   CONTINUE                         08220000
FHWD     DS    0H                                                       08230045
         LH    R11,CONDATA             PICK UP HALFWORD                 08240045
         LTR   R11,R11                 TEST CONSTANT VALUE              08250000
         BM    FHEX                    NEGATIVE, TREAT AS HEX           08260000
         BNZ   FHCMAX                  NOT ZERO, CHECK MAX VALUE        08270000
         MVC   OPNDS(4),=C'H''0'''     SET OPERAND FOR ZERO             08280000
         B     FCWRT                   CONTINUE                         08290000
FHCMAX   DS    0H                                                       08300045
         CH    R11,=H'9999'            VALUE EXCEEDS 9,999              08310045
         BH    FHEX                    YES, TREAT AS HEX                08320000
         CVD   R11,DBLWD               CONVERT TO PACKED                08330000
         OI    DBLWD+7,X'0F'           CLEAR SIGN TO F                  08340000
         MVC   OPNDS(2),=C'H'''        SET DELIMITER IN OPERAND         08350000
         UNPK  OPNDS+2(4),DBLWD+5(3)   UNPACK VALUE TO OPERAND          08360000
         MVI   OPNDS+6,C''''           ENDING DELIMITER                 08370000
         B     FCWRT                   CONTINUE                         08380000
FCHAR    DS    0H                                                  DSK  08390027
         CLC   CONLEN,=H'1'            Length > 1 for now          DSK  08400027
         BH    FCHAR1                  Yes, do in character        DSK  08410027
         TM    PRMOPT,CONALHEX         DC all in hex option set    DSK  08420027
         BO    FHEX                    Yes                         DSK  08430027
FCHAR1   DS    0H                                                  DSK  08440027
         MVC   OPNDS(2),=C'C'''        OPERAND DELIMITER FOR CHARACTER  08450027
         SR    R11,R11                 GET DATA LENGTH             DSK1 08460028
         ICM   R11,3,CONLEN            GET DATA LENGTH             DSK1 08470028
         BCTR  R11,0                   LENGTH CODE                 DSK1 08480028
         STC   R11,FMCNT+1             SET MOVE LENGTH                  08490000
FMCNT    MVC   OPNDS+2,CONDATA         DATA TO OPERAND                  08500000
         LA    R11,OPNDS+3(R11)        STEP PAST OPERAND DATA           08510036
         MVI   0(R11),C''''            ENDING QUOTE                     08520000
         B     FCWRT                   CONTINUE                         08530000
FSYMBOL  DS    0H                                                       08540045
         CLC   CONSYM,BLANX            IS IT BLANK                      08550045
         BE    FHEX                    YES, TREAT AS HEX                08560000
         CLC   CONLEN,=H'4'            LENGTH IS 4                 DSK1 08570052
         BH    FHEX                    NO, GREATER                      08580000
         BE    AC4                     YES, 4 BYTES                     08590000
         CLC   CONLEN,=H'3'            LENGTH IS 3                 DSK1 08600028
         BE    AC3                     YES                              08610000
         CLC   CONLEN,=H'2'            LENGTH IS 2                 DSK1 08620052
         BE    AC2                     YES                              08630000
         MVC   OPNDS+1(2),=C'L1'       OPND LENGTH                      08640000
         B     FSLHE1                  CONTINUE                         08650000
AC2      DS    0H                                                       08660045
         MVC   OPNDS+1(2),=C'L2'       OPND LGTH                        08670045
         B     FSLHE1                  CONTINUE                         08680000
AC3      DS    0H                                                       08690045
         MVC   OPNDS+1(2),=C'L3'       OPND LENGTH                      08700045
         B     FSLHE1                  CONTINUE                         08710000
AC4      DS    0H                                                       08720045
         LA    R11,OPNDS+1             STEP TO ( POS                    08730045
         B     FSLHE                   CONTINUE                         08740000
FSLHE1   DS    0H                                                       08750045
         LA    R11,OPNDS+3             STEP TO ( POS                    08760045
FSLHE    DS    0H                                                       08770045
         MVI   0(R11),C'('             DELIMITER                        08780045
         MVC   1(8,R11),CONSYM         SYMBOL TO RECORD                 08790000
         LA    R11,9(,R11)             @ RHE SYMBOL IN OPERAND          08800036
FRHE     DS    0H                                                       08810045
         CLI   0(R11),C' '             CHARACTER IS BLANK               08820045
         BNE   SETRPAR                 NO                               08830000
         BCT   R11,FRHE                LOOP TO FIND RHE                 08840000
SETRPAR  DS    0H                                                       08850045
         MVI   1(R11),C')'             SET CLOSING PAREN                08860045
         CLI   CONTYPE,C'W'            WXTRN REFERENCE              DSK 08870019
         BNE   FCWRT                   NO                           DSK 08880019
         MVI   OPNDS,C'A'              CHANGE TO AN ADCON           DSK 08890019
         B     FCWRT                   CONTINUE                         08900000
FHEX     DS    0H                                                       08910045
         MVC   OPNDS(2),=C'X'''        TYPE AND BEGIN QUOTE             08920045
         LA    R12,CONDATA             @ CONSTANT DATA                  08930000
         BAL   R9,HEXPRT4              CONVERT TO PRINTABLE             08940000
         SR    R12,R12                 GET DATA LENGTH             DSK1 08950028
         ICM   R12,3,CONLEN            GET DATA LENGTH             DSK1 08960028
         SLL   R12,1                   DOUBLE IT                        08970000
         BCTR  R12,0                   -1 = LENGTH CODE            DSK1 08980028
         STC   R12,MVHX+1              SET MOVE LENGTH                  08990000
MVHX     DS    0H                                                       09000045
         MVC   OPNDS+2(1),PRTABL       HEX CHARS TO OPERAND             09010045
         LA    R12,OPNDS+2(R12)        OPERAND END ADDRESS              09020036
         MVI   1(R12),C''''            ENDING QUOTE                     09030000
         B     FCWRT                   CONTINUE                         09040000
FCWRT    DS    0H                                                   DSK 09050016
         BAL   R9,TXTFMT               GO FORMAT HEX DATA               09060000
         BAL   R9,WRTOUT               WRITE RECORD                 DSK 09070016
         BAL   R9,PRINT                GO PRINT IT                      09080000
         CLI   CONTYPE,C'W'            WXTRN REFERENCE              DSK 09090019
         BNE   FCCLR                   NO                           DSK 09100019
         DROP  R6                                                   DSK 09110021
         L     R1,LBLTBL               LABEL TABLE ADDRESS          DSK 09120021
         USING LABELD,R1                                            DSK 09130021
FCWXSC   DS    0H                                                   DSK 09140021
         CLC   LBLNAME,CONSYM          FOUND SYMBOL?                DSK 09150021
         BE    FCWXCK                  YES, CONTINUE                DSK 09160021
         LA    R1,L'LABEL(,R1)         TO NEXT LABEL                DSK 09170021
         C     R1,ENDLBL               END OF TABLE                 DSK 09180021
         BL    FCWXSC                  NO, CONTINUE SCAN            DSK 09190021
         B     FCCLR                   SHOULD NOT HAPPEN            DSK 09200021
FCWXCK   DS    0H                                                   DSK 09210021
         CLI   LBLLEN,X'FF'            ALREDY GENERATE WXTRN        DSK 09220021
         BE    FCCLR                   YES, SKIP IT                 DSK 09230021
         MVI   LBLLEN,X'FF'            SET WE GENERATED WXTRN       DSK 09240021
         DROP  R1                                                   DSK 09250021
         USING LABELD,R6                                            DSK 09260021
         MVC   MNEMONIC(5),=C'WXTRN'   GENERATE A WEAK EXTERN       DSK 09270019
         MVC   OPNDS(8),CONSYM         SYMBOL TO RECORD             DSK 09280019
         MVC   PRT(80),WORKREC         COPY TO PRINT                DSK 09290019
         BAL   R9,WRTOUT               WRITE RECORD                 DSK 09300019
         BAL   R9,PRINT                GO PRINT IT                  DSK 09310019
FCCLR    DS    0H                                                       09320045
         MVI   CONPROG,0               RESET CONSTANT IN PROGRESS       09330045
         MVC   CONNAME,BLANX           CLEAR NAME                       09340000
         MVI   CONTYPE,0               RESET TYPE                       09350000
         XC    CONDATA,CONDATA         CLEAR CONSTANT DATA              09360000
         MVC   CONSYM,BLANX            CLEAR SYMBOL                     09370000
         XC    CONLEN,CONLEN           CLEAR LENGTH                     09380000
         MVC   CONLOC,XZROS            CLEAR LOCATION                   09390000
         MVC   CONOFST,XZROS           CLEAR OFFSET TO CONSTANT         09400000
         L     R9,FC9                  GET RETURN ADDR                  09410000
         BR    R9                      EXIT                             09420000
******************************************************************      09430000
*                                                                *      09440000
* THIS ROUTINE FORMATS RR-FORMAT INSTRUCTIONS FOR OUTPUT.        *      09450000
*                                                                *      09460000
******************************************************************      09470000
RROPND   DS    0H                      *** RR FORMAT INSTRUCTIONS ***   09480036
         CLI   0(R7),X'05'             IS IT BALR                       09490000
         BNE   RRSTRT                                                   09500000
         CLI   1(R7),X'EF'             IS IT BALR 14,15                 09510000
         BE    RRSTDL                  YES                              09520000
         TM    1(R7),X'0F'             NO, IS R2 = 0                    09530000
         BNZ   RRNSTD                  NO                               09540000
*        TM    PRMOPT,DBGNOCMT         Skip comments               DSK1 09550028
*        BO    NOCMT04                 Yes                         DSK1 09560028
*        MVC   COMMENT(11),=C'ADDRESS SET'                         DSK1 09570028
NOCMT04  DS    0H                                                   DSK 09580017
         B     RRSTRT                  CONTINUE                         09590000
RRSTDL   DS    0H                                                   DSK 09600017
*        TM    PRMOPT,DBGNOCMT         Skip comments               DSK1 09610028
*        BO    NOCMT06                 Yes                         DSK1 09620028
*        MVC   COMMENT(11),=C'STD LINKAGE'                         DSK1 09630028
NOCMT06  DS    0H                                                   DSK 09640017
         B     RRSTRT                  CONTINUE                         09650000
RRNSTD   DS    0H                                                   DSK 09660017
*        TM    PRMOPT,DBGNOCMT         Skip comments               DSK1 09670028
*        BO    NOCMT08                 Yes                         DSK1 09680028
*        MVC   COMMENT(14),=C'NONSTD LINKAGE'                      DSK1 09690028
NOCMT08  DS    0H                                                   DSK 09700017
RRSTRT   DS    0H                                                       09710045
         SR    R1,R1                   CLEAR WORK                       09720045
         IC    R1,TEXT+1               GET 2ND BYTE                     09730000
         SRL   R1,4                    SHIFT OUT R2                     09740000
         CVD   R1,DBLWD                CONVERT                          09750000
         OI    DBLWD+7,X'0F'           CLEAR SIGN                       09760000
         UNPK  DBLWD(2),DBLWD+6(2)     UNPACK                           09770000
         MVI   OPNDS,C'R'              BEGIN R1 OPERAND                 09780000
         CH    R1,=H'10'               REG NBR > 9                      09790052
         BL    RR11                    NO, 0-9                          09800000
         MVC   OPNDS+1(2),DBLWD        YES, 10-15                       09810000
         LA    R1,OPNDS+3              TO NEXT POS                      09820000
         B     RRCMA                   CONTINUE                         09830000
RR11     DS    0H                                                       09840045
         MVC   OPNDS+1(1),DBLWD+1      MOVE REG NBR                     09850045
         LA    R1,OPNDS+2              TO NEXT POS                      09860000
RRCMA    DS    0H                                                       09870045
         CLI   TEXT,X'04'              IS IT SPM                        09880045
         BNE   RRCMA1                  NO                               09890000
         TM    1(R7),X'0F'             YES, IS R2 FIELD = 0             09900000
         BZ    RRXIT                   YES, GOOD INSTR                  09910000
         B     4(,R9)                  ERROR RETURN (NOT INSTR)         09920036
RRCMA1   DS    0H                                                       09930045
         MVC   0(2,R1),=C',R'          DELIMITERS                       09940045
         PACK  DBLWD(1),TEXT+1(1)      FLIP 2ND BYTE                    09950000
         SR    R15,R15                 CLEAR WORK                       09960000
         IC    R15,DBLWD               GET R2R1                         09970000
         SRL   R15,4                   SHIFT OUT R1                     09980000
         CVD   R15,DBLWD               CONVERT                          09990000
         OI    DBLWD+7,X'0F'           CLEAR SIGN                       10000000
         UNPK  DBLWD(2),DBLWD+6(2)     UNPACK                           10010000
         CH    R15,=H'10'              R2 > 9                           10020052
         BL    RR21                    NO, 0-9                          10030000
         MVC   2(2,R1),DBLWD           YES, MOVE REG 10-15              10040000
         BR    R9                      EXIT                             10050000
RR21     DS    0H                                                       10060045
         MVC   2(1,R1),DBLWD+1         MOVE REG 0-9                     10070045
RRXIT    DS    0H                                                       10080045
         BR    R9                      EXIT                             10090045
******************************************************************      10100000
*                                                                *      10110000
* THIS ROUTINE IS CALLED BY THE INSTR ROUTINE TO FORMAT RX-TYPE  *      10120000
* INSTRUCTIONS. THE BDXADR ROUTINE IS CALLED TO FORMAT THE       *      10130000
* STORAGE OPERAND.                                               *      10140000
*                                                                *      10150000
******************************************************************      10160000
RXOPND   DS    0H                      *** RX FORMAT INSTRUCTIONS ***   10170036
         CLI   0(R7),X'45'             IS IT BAL OP CODE                10180000
         BNE   RXSTRT                  NO                               10190000
*        TM    PRMOPT,DBGNOCMT         Skip comments               DSK1 10200028
*        BO    NOCMT10                 Yes                         DSK1 10210028
*        MVC   COMMENT(7),=C'PERFORM'                              DSK1 10220028
NOCMT10  DS    0H                                                   DSK 10230017
         TM    1(R7),X'E0'             R1 = 0 OR 1                      10240000
         BNZ   RXSTRT                  NO                               10250000
*        TM    PRMOPT,DBGNOCMT         Skip comments               DSK1 10260028
*        BO    NOCMT12                 Yes                         DSK1 10270028
*        MVC   COMMENT(13),=C'PARM SET BRCH'                       DSK1 10280028
NOCMT12  DS    0H                                                   DSK 10290017
RXSTRT   DS    0H                                                       10300045
         SR    R1,R1                   CLEAR WORK                       10310045
         IC    R1,TEXT+1               GET R1X2                         10320000
         SRL   R1,4                    SHIFT OUT X2                     10330000
         CVD   R1,DBLWD                CONVERT                          10340000
         OI    DBLWD+7,X'0F'           CLEAR SIGN                       10350000
         UNPK  DBLWD(2),DBLWD+6(2)     UNPACK                           10360000
         MVI   OPNDS,C'R'              BEGIN 1ST OPERAND                10370000
         CH    R1,=H'10'               R1 < 10                          10380052
         BL    RXR11                   YES, 0-9                         10390000
         MVC   OPNDS+1(2),DBLWD        NO, MOVE REG 10-15               10400000
         LA    R15,OPNDS+3             TO NEXT POS                      10410000
         B     RXCMA                   CONTINUE                         10420000
RXR11    DS    0H                                                       10430045
         MVC   OPNDS+1(1),DBLWD+1      MOVE REG 0-9                     10440045
         LA    R15,OPNDS+2             TO NEXT POS                      10450000
RXCMA    DS    0H                                                       10460045
         MVI   0(R15),C','             DELIMITER                        10470045
         PACK  DBLWD(1),TEXT+1(1)      FLIP 2ND BYTE                    10480000
         SR    R10,R10                 CLEAR WORK                       10490000
         IC    R10,DBLWD               PICK UP X2R1                     10500000
         SRL   R10,4                   SHIFT OUT R1                     10510000
         SR    R11,R11                 CLEAR WORK                       10520000
         ICM   R11,3,TEXT+2            GET BDDD                         10530000
         BAL   R9,BDXADR               CONVERT RX ADDRESS               10540000
         STC   R10,BDXMVC+1            SET MOVE LENGTH                  10550000
BDXMVC   MVC   1(1,R15),OPNDWK         MOVE RX OPERAND                  10560000
         L     R9,OPND9                GET RETURN ADDR                  10570000
         BR    R9                      EXIT                             10580000
******************************************************************      10590000
*                                                                *      10600000
* THIS ROUTINE IS CALLED BY THE INSTR ROUTINE TO FORMAT S-TYPE   *      10610000
* INSTRUCTIONS. THE BDADR ROUTINE IS CALLED TO FORMAT THE        *      10620000
* STORAGE OPERAND.                                               *      10630000
*                                                                *      10640000
******************************************************************      10650000
SOPND    DS    0H                      *** S FORMAT INSTRUCTIONS ***    10660036
         CLI   1(R7),0                 BYTE 2 OF INSTR IS ZERO          10670000
         BE    SCK2                    YES                              10680000
         CLI   0(R7),X'80'             NO, IS IT SSM                    10690000
         BE    4(,R9)                  YES, NOT INSTR                   10700036
         CLI   0(R7),X'82'             NO, IS IT LPSW                   10710000
         BE    4(,R9)                  YES, NOT INSTR                   10720036
         CLI   0(R7),X'93'             NO, IS IT TS                     10730000
         BE    4(,R9)                  YES, NOT INSTR                   10740036
SCK2     DS    0H                                                       10750045
         CLI   0(R7),X'B2'             OP-CODE IS B2                    10760045
         BNE   SSTRT                   NO                               10770000
         CLC   2(2,R7),XZROS           3RD AND 4TH BYTES ZERO           10780000
         BE    SSTRT                   YES                              10790000
         CLI   1(R7),X'0B'             IPK INSTRUCTION                  10800000
         BE    4(,R9)                  YES, NOT INSTR                   10810036
         CLI   1(R7),X'0D'             PTLB INSTR                       10820000
         BE    4(,R9)                  YES, NOT INSTR                   10830036
SSTRT    DS    0H                                                       10840045
         SR    R11,R11                 CLEAR WORK                       10850045
         ICM   R11,3,TEXT+2            GET BDDD                         10860000
         BAL   R9,BDADR                CONVERT BDDD ADDRESS             10870000
         STC   R10,SOPMVC+1            SET MOVE LENGTH                  10880000
SOPMVC   DS    0H                                                       10890045
         MVC   OPNDS,OPNDWK            MOVE OPERAND                     10900045
         L     R9,OPND9                GET RETURN ADDR                  10910000
         BR    R9                      EXIT                             10920000
******************************************************************      10930000
*                                                                *      10940000
* THIS ROUTINE IS CALLED BY THE INSTR ROUTINE TO FORMAT SI-TYPE  *      10950000
* INSTRUCTIONS. THE BDADR ROUTINE IS CALLED TO FORMAT THE        *      10960000
* STORAGE OPERAND.                                               *      10970000
*                                                                *      10980000
******************************************************************      10990000
SIOPND   DS    0H                      *** SI FORMAT INSTRUCTIONS ***   11000036
         SR    R11,R11                 CLEAR WORK                       11010000
         ICM   R11,3,TEXT+2            GET BDDD ADDRESS                 11020000
         BAL   R9,BDADR                CONVERT ADDRESS                  11030000
         STC   R10,SIOMVC+1            SET MOVE LENGTH                  11040000
SIOMVC   DS    0H                                                       11050045
         MVC   OPNDS,OPNDWK            MOVE BDDD OPERAND                11060045
         LA    R15,OPNDS+1(R10)        TO NEXT POS                      11070036
         MVI   0(R15),C','             DELIMITER                        11080000
         L     R1,=A(CHARTRAN)                                      DSK 11090036
         TRT   TEXT+1(1),0(R1)         TEST IF CHARACTER                11100036
         BNZ   HEXIMM                  NO, HEX                          11110000
         CLI   TEXT,X'95'              IS IT CLI                        11120000
         BE    CHIMM                   YES                              11130000
         CLI   TEXT,X'92'              IS IT MVI                        11140000
         BNE   HEXIMM                  NO                               11150000
CHIMM    DS    0H                                                       11160045
         MVC   1(2,R15),=C'C'''        DELIMITER                        11170045
         MVC   3(1,R15),TEXT+1         CHARACTER TO OPERAND             11180000
         MVI   4(R15),C''''            ENDING DELIMITER                 11190000
         L     R9,OPND9                GET RETURN ADDR                  11200000
         BR    R9                      EXIT                             11210000
HEXIMM   DS    0H                                                       11220045
         MVC   1(2,R15),=C'X'''        DELIMITER FOR HEX                11230045
         LA    R12,TEXT+1              @ HEX BYTE                       11240000
         BAL   R9,HEXPRT1              CONVERT                          11250000
         MVC   3(2,R15),PRTABL         PRINTABLE HEX TO OPERAND         11260000
         MVI   5(R15),C''''            FINAL QUOTE                      11270000
         L     R9,OPND9                GET RETURN ADDR                  11280000
         BR    R9                      EXIT                             11290000
******************************************************************      11300000
*                                                                *      11310000
* THIS ROUTINE IS CALLED BY THE INSTR ROUTINE TO FORMAT RS-TYPE  *      11320000
* INSTRUCTIONS. THE BDADR ROUTINE IS CALLED TO FORMAT THE        *      11330000
* STORAGE OPERAND.                                               *      11340000
*                                                                *      11350000
******************************************************************      11360000
RSOPND   DS    0H                      *** RS FORMAT INSTRUCTIONS ***   11370036
         CLI   TEXT,X'90'              IS IT STM                        11380000
         BE    RSSTM                   YES                              11390000
         CLI   TEXT,X'98'              IS IT LM                         11400000
         BNE   RSCLR1                  NO                               11410000
*        TM    PRMOPT,DBGNOCMT         Skip comments               DSK1 11420028
*        BO    NOCMT14                 Yes                         DSK1 11430028
*        MVC   COMMENT(12),=C'RESTORE REGS'                        DSK1 11440028
NOCMT14  DS    0H                                                   DSK 11450017
         B     RSCLR1                  CONTINUE                         11460000
RSSTM    DS    0H                                                   DSK 11470017
*        TM    PRMOPT,DBGNOCMT         Skip comments               DSK1 11480028
*        BO    NOCMT16                 Yes                         DSK1 11490028
*        MVC   COMMENT(9),=C'SAVE REGS'                            DSK1 11500028
NOCMT16  DS    0H                                                   DSK 11510017
RSCLR1   DS    0H                                                       11520045
         SR    R1,R1                   CLEAR WORK                       11530045
         IC    R1,TEXT+1               PICK UP R1R3                     11540000
         SRL   R1,4                    SHIFT OUT R3                     11550000
         CVD   R1,DBLWD                CONVERT                          11560000
         OI    DBLWD+7,X'0F'           CLEAR SIGN                       11570000
         UNPK  DBLWD(2),DBLWD+6(2)     UNPACK                           11580000
         MVI   OPNDS,C'R'              BEGINNING OPERAND 1              11590000
         CH    R1,=H'10'               REG NBR < 10                     11600052
         BL    RSR11                   YES                              11610000
         MVC   OPNDS+1(2),DBLWD        MOVE REG 10-15                   11620000
         LA    R15,OPNDS+3             TO NEXT POS                      11630000
         B     RSCMA                   CONTINUE                         11640000
RSR11    DS    0H                                                       11650045
         MVC   OPNDS+1(1),DBLWD+1      MOVE REG 0-9                     11660045
         LA    R15,OPNDS+2             TO NEXT POS                      11670000
RSCMA    DS    0H                                                       11680045
         CLI   0(R7),X'88'             IS IT SHIFT INSTR                11690045
         BL    RSCMA1                  NO                               11700000
         CLI   0(R7),X'8F'             IS IT SHIFT INSTR                11710000
         BH    RSCMA1                  NO                               11720000
         TM    1(R7),X'0F'             SHIFT, IS R3 POS = 0             11730000
         BZ    RSBDD                   YES, GOOD SHIFT                  11740000
         B     4(,R9)                  NO, NOT INSTR                    11750045
RSCMA1   DS    0H                                                       11760045
         MVC   0(2,R15),=C',R'         DELIMITERS                       11770045
         CLI   0(R7),X'BD'             CLM, STCM, OR ICM                11780000
         BL    RSPK2                   NO                               11790000
         CLI   0(R7),X'BF'             CLM,STCM, OR ICM                 11800000
         BH    RSPK2                   NO                               11810000
         BCTR  R15,0                   CLM, STCM, ICM HAVE MASK IN R3 P 11820045
RSPK2    DS    0H                                                       11830045
         PACK  DBLWD(1),TEXT+1(1)      FLIP 2ND BYTE                    11840045
         SR    R1,R1                   CLEAR WORK                       11850000
         IC    R1,DBLWD                GET R3R1                         11860000
         SRL   R1,4                    SHIFT OUT R1                     11870000
         CVD   R1,DBLWD                CONVERT                          11880000
         OI    DBLWD+7,X'0F'           CLEAR SIGN                       11890000
         UNPK  DBLWD(2),DBLWD+6(2)     UNPACK                           11900000
         CH    R1,=H'10'               REG NBR < 10                     11910052
         BL    RSR31                   YES, 0-9                         11920000
         MVC   2(2,R15),DBLWD          MOVE REG 10-15                   11930000
         LA    R15,4(,R15)             TO NEXT POS                      11940036
         B     RSBDD                   CONTINUE                         11950000
RSR31    DS    0H                                                       11960045
         MVC   2(1,R15),DBLWD+1        MOVE REG 0-9                     11970045
         LA    R15,3(,R15)             TO NEXT POS                      11980036
RSBDD    DS    0H                                                       11990045
         MVI   0(R15),C','             DELIMITER                        12000045
         SR    R11,R11                 CLEAR WORK                       12010000
         ICM   R11,3,TEXT+2            GET BDD ADDRESS                  12020000
         BAL   R9,BDADR                CONVERT BDDD ADDRESS             12030000
         STC   R10,RSMVC+1             SET MOVE LENGTH                  12040000
RSMVC    MVC   1(1,R15),OPNDWK         MOVE BDDD ADDRESS                12050000
         L     R9,OPND9                GET RETURN ADDR                  12060000
         BR    R9                      EXIT                             12070000
******************************************************************      12080000
*                                                                *      12090000
* THIS ROUTINE IS CALLED BY THE INSTR ROUTINE TO FORMAT SS-TYPE  *      12100000
* INSTRUCTIONS OF THE SINGLE LENGTH VARIETY. THE BDLADR ROUTINE  *      12110000
* IS CALLED TO FORMAT THE 1ST STRG OPND, AND BDADR FOR THE 2ND.  *      12120000
*                                                                *      12130000
******************************************************************      12140000
SS1OPND  DS    0H                      *** SS FORMAT INSTRUCTIONS - SIN 12150036
         SR    R10,R10                 CLEAR WORK                       12160000
         IC    R10,TEXT+1              GET LENGTH CODE                  12170000
         SR    R11,R11                 CLEAR WORK                       12180000
         ICM   R11,3,TEXT+2            GET BDDD ADDRESS                 12190000
         BAL   R9,BDLADR               CONVERT ADDRESS                  12200000
         STC   R10,SS1MV1+1            SET MOVE LENGTH                  12210000
SS1MV1   MVC   OPNDS,OPNDWK            MOVE ADDRESS                     12220000
         LA    R15,OPNDS+1(R10)        TO NEXT POS                      12230036
         MVI   0(R15),C','             DELIMITER                        12240000
         SR    R11,R11                 CLEAR WORK                       12250000
         ICM   R11,3,TEXT+4            GET SECOND BDDD ADDRESS          12260000
         BAL   R9,BDADR                CONVERT ADDRESS                  12270000
         STC   R10,SS1MV2+1            SET MOVE LENGTH                  12280000
SS1MV2   MVC   1(1,R15),OPNDWK         MOVE 2ND OPERAND                 12290000
         L     R9,OPND9                GET RETURN ADDR                  12300000
         BR    R9                      EXIT                             12310000
******************************************************************      12320000
*                                                                *      12330000
* THIS ROUTINE IS CALLED BY THE INSTR ROUTINE TO FORMAT SS-TYPE  *      12340000
* INSTRUCTIONS OF THE DOUBLE LENGTH VARIETY. THE BDLADR ROUTINE  *      12350000
* IS CALLED TO FORMAT THE STORAGE OPERANDS.                      *      12360000
*                                                                *      12370000
******************************************************************      12380000
SS2OPND  DS    0H                      *** SS FORMAT INSTRUCTIONS - 2 L 12390036
         SR    R10,R10                 CLEAR WORK                       12400000
         IC    R10,TEXT+1              GET L1L2                         12410000
         SRL   R10,4                   SHIFT OUT L2                     12420000
         SR    R11,R11                 CLEAR WORK                       12430000
         ICM   R11,3,TEXT+2            GET BDDD ADDRESS                 12440000
         BAL   R9,BDLADR               CONVERT ADDRESS                  12450000
         STC   R10,SS2MV1+1            SET MOVE LENGTH                  12460000
SS2MV1   MVC   OPNDS,OPNDWK            MOVE 1ST OPERAND                 12470000
         LA    R15,OPNDS+1(R10)        TO NEXT POS                      12480036
         MVI   0(R15),C','             DELIMITER                        12490000
         SR    R11,R11                 CLEAR WORK                       12500000
         ICM   R11,3,TEXT+4            GET 2ND BDDD ADDR                12510000
         PACK  DBLWD(1),TEXT+1(1)      FLIP LENGTH BYTE                 12520000
         SR    R10,R10                 CLEAR WORK                       12530000
         IC    R10,DBLWD               PICK UP L2L1                     12540000
         SRL   R10,4                   SHIFT OUT L1                     12550000
         CLI   TEXT,X'F0'              SRP OP-CODE                      12560000
         BE    SRPOP2                  YES                              12570000
         BAL   R9,BDLADR               CONVERT ADDRESS                  12580000
         STC   R10,SS2MV2+1            SET MOVE LENGTH                  12590000
SS2MV2   MVC   1(1,R15),OPNDWK         MOVE 2ND OPERAND                 12600000
SS2XIT   DS    0H                                                       12610045
         L     R9,OPND9                GET RETURN ADDR                  12620045
         BR    R9                      EXIT                             12630000
SRPOP2   DS    0H                                                       12640045
         BAL   R9,BDADR                GO BUILD OPERAND 2               12650045
         STC   R10,SRMV1+1             SET MOVE LENGTH                  12660000
SRMV1    MVC   1(1,R15),OPNDWK         MOVE OPERAND 2                   12670000
         LA    R15,2(R10,R15)          TO NEXT OPERAND POS  FIX***      12680000
         PACK  DBLWD(1),TEXT+1(1)      FLIP LENGTH BYTE                 12690000
         SR    R10,R10                 CLEAR WORK                       12700000
         IC    R10,DBLWD               PICK UP I3L1                     12710000
         SRL   R10,4                   SHIFT OUT L1                     12720000
         CVD   R10,DBLWD               CONVERT I3                       12730000
         OI    DBLWD+7,X'0F'           CLEAR SIGN                       12740000
         MVI   0(R15),C','             OPERAND SEPARATOR    FIX***      12750000
         UNPK  1(1,R15),DBLWD+7(1)     UNPACK I3 TO OPERAND FIX***      12760000
         CH    R2,=H'10'               I3 < 10                          12770052
         BL    SS2XIT                  YES                              12780000
         UNPK  1(2,R15),DBLWD+6(2)     NO, UNPACK MORE                  12790000
         B     SS2XIT                  CONTINUE                         12800000
******************************************************************      12810000
*                                                                *      12820000
* THIS ROUTINE IS CALLED BY THE INSTR ROUTINE TO FORMAT COND-    *      12830000
* ITIONAL BRANCH INSTRUCTIONS. AN ATTEMPT IS MADE TO USE THE     *      12840000
* EXTENDED MNEMONICS WHERE POSSIBLE. FOR RR-TYPE BRANCHES, ONLY  *      12850000
* THE BR AND NOPR MNEMONICS ARE USED. FOR RX-TYPE BRANCHES, THE  *      12860000
* FULL SET OF EXTENDED MNEMONICS IS USED. THE TYPES USED ARE     *      12870000
* ARITHMETIC, COMPARE, AND 8=ZERO TYPES. THE SET TO BE USED IS   *      12880000
* DETERMINED BY THE TYPE SAVED BY THE LAST CONDITION-CODE-SETTING*      12890000
* INSTRUCTION GENERATED.                                         *      12900000
*                                                                       12910000
******************************************************************      12920000
BCOPND   DS    0H                      *** CONDITIONAL BRANCH INSTRUCTI 12930036
         TM    TEXT+1,X'F0'            UNCONDITIONAL BRANCH             12940000
         BZ    NOPS                    NO, NOP                          12950000
         BO    UNCNDS                  YES, UNCONDITIONAL               12960000
         SR    R11,R11                 CLEAR WORK                       12970000
         IC    R11,TEXT+1              PICK UP M1X2                     12980000
         SRL   R11,4                   SHIFT OUT ALL BUT M1             12990000
         CLI   TEXT,X'07'              BCR OP CODE                      13000000
         BE    NOEXTND                 YES, NO EXTENDED MNEMONICS       13010000
         CLI   CCTYPE,0                LAST INSTR SET CC                13020000
         BE    NOEXTND                 NO                               13030000
         TM    CCTYPE,ARITH            YES, WAS IT ARITHMETIC           13040000
         BO    EXTARITH                YES                              13050000
         TM    CCTYPE,CPR              WAS IT COMPARE                   13060000
         BO    EXTCPR                  YES                              13070000
         TM    CCTYPE,ZRO8             IS IT VALID FOR 8 = BZ           13080000
         BO    EXTZRO                  YES                              13090000
NOEXTND  DS    0H                                                       13100045
         CVD   R11,DBLWD               CONVERT                          13110045
         OI    DBLWD+7,X'0F'           CLEAR SIGN                       13120000
         UNPK  DBLWD(2),DBLWD+6(2)     UNPACK                           13130000
         CH    R11,=H'10'              MASK < 10                        13140052
         BL    BCM1                    YES, SINGLE DIGIT MASK           13150000
         MVC   OPNDS(2),DBLWD          2-DIGIT MASK TO OPERAND          13160000
         LA    R15,OPNDS+2             TO NEXT POS                      13170000
         B     BCCMA                   CONTINUE                         13180000
BCM1     DS    0H                                                       13190045
         MVC   OPNDS(1),DBLWD+1        SINGLE DIGIT MASK TO OPERAND     13200045
         LA    R15,OPNDS+1             TO NEXT POS                      13210000
BCCMA    DS    0H                                                       13220045
         MVI   0(R15),C','             DELIMITER                        13230045
         CLI   TEXT,X'07'              RR BRANCH                        13240000
         BE    BCROPND                 YES                              13250000
BCXOPND  DS    0H                                                       13260045
         PACK  DBLWD(1),TEXT+1(1)      PACK 2ND BYTE                    13270045
         SR    R10,R10                 CLEAR WORK                       13280000
         IC    R10,DBLWD               PICK UP X2M1                     13290000
         SRL   R10,4                   SHIFT OUT M1                     13300000
         SR    R11,R11                 CLEAR WORK                       13310000
         ICM   R11,3,TEXT+2            PICK UP BDDD ADDRESS             13320000
         BAL   R9,BDXADR               CONVERT ADDRESS                  13330000
         STC   R10,BLDXMVC+1           SET MOVE LENGTH                  13340000
BLDXMVC  MVC   1(1,R15),OPNDWK         MOVE OPERAND                     13350000
         B     BCOXIT                  GO TO EXIT                       13360000
BCROPND  DS    0H                                                       13370045
         MVI   1(R15),C'R'             REGISTER DELIMITER               13380045
         SR    R10,R10                 CLEAR WORK                       13390000
         PACK  DBLWD(1),TEXT+1(1)      FLIP 2ND BYTE                    13400000
         IC    R10,DBLWD               PICK UP R2M1                     13410000
         SRL   R10,4                   SHIFT OUT M1                     13420000
         CVD   R10,DBLWD               CONVERT                          13430000
         OI    DBLWD+7,X'0F'           CLEAR SIGN                       13440000
         UNPK  DBLWD(2),DBLWD+6(2)     UNPACK                           13450000
         CH    R10,=H'10'              REG NBR < 10                     13460052
         BL    BCRR1                   YES, 0-9                         13470000
         MVC   2(2,R15),DBLWD          MOVE 2-DIGIT REG NBR             13480000
         B     BCOXIT                  GO TO EXIT                       13490000
BCRR1    DS    0H                                                       13500045
         MVC   2(1,R15),DBLWD+1        MOVE 1-DIGIT REG NBR             13510045
         B     BCOXIT                  GO TO EXIT                       13520000
NOPS     DS    0H                                                       13530045
         CLI   TEXT,X'07'              RR NOP                           13540045
         BNE   BCXNOP                  NO, RX                           13550000
         MVC   MNEMONIC,=CL5'NOPR'     SET MNEMONIC                     13560000
         LA    R15,OPNDS-1             TO OPND POS                      13570000
         B     BCROPND                 FINISH                           13580000
BCXNOP   DS    0H                                                       13590045
         MVC   MNEMONIC,=CL5'NOP'      SET MNEMONIC                     13600045
         LA    R15,OPNDS               TO OPND POS                      13610000
         B     BCXOPND                 FINISH                           13620000
UNCNDS   DS    0H                                                       13630045
         CLI   TEXT,X'07'              IS IT RR BRANCH                  13640045
         BNE   BCXBRCH                 NO, RX                           13650000
         MVC   MNEMONIC,=CL5'BR'       SET MNEMONIC                     13660000
         LA    R15,OPNDS-1             OPERAND ADDR                     13670000
         CLI   TEXT+1,X'FE'            IS IT BR 14                      13680000
         BNE   BCROPND                 NO                               13690000
*        TM    PRMOPT,DBGNOCMT         Skip comments               DSK1 13700028
*        BO    NOCMT18                 Yes                         DSK1 13710028
*        MVC   COMMENT(4),=C'EXIT'     COMMENT                     DSK1 13720028
NOCMT18  DS    0H                                                   DSK 13730017
         B     BCROPND                 FINISH FORMATTING                13740000
BCXBRCH  DS    0H                                                       13750045
         MVC   MNEMONIC(5),=CL5'B'     SET MNEMONIC                     13760045
BCXTFIN  DS    0H                                                       13770045
         LA    R15,OPNDS-1             SET OPND POS                     13780045
         B     BCXOPND                 FINISH FORMAT                    13790000
BCOXIT   DS    0H                                                       13800045
         L     R9,OPND9                GET RETURN ADDR                  13810045
         BR    R9                      EXIT                             13820000
EXTARITH DS    0H                                                       13830045
         CH    R11,=H'8'               COND CODE = 8                    13840052
         BE    ARBZ                    YES                              13850000
         BL    ARLOW                   NO, LOWER                        13860000
         CH    R11,=H'14'              COND CODE = 14                   13870052
         BE    ARBNO                   YES                              13880000
         CH    R11,=H'13'              COND CODE = 13                   13890052
         BE    ARBNP                   YES                              13900000
         CH    R11,=H'11'              COND CODE = 11                   13910052
         BE    ARBNM                   YES                              13920000
         B     NOEXTND                 NO, NOT EXTENDED                 13930000
ARLOW    DS    0H                                                       13940045
         CH    R11,=H'7'               COND CODE = 7                    13950052
         BE    ARBNZ                   YES                              13960000
         CH    R11,=H'1'               COND CODE = 1                    13970052
         BE    ARBO                    YES                              13980000
         CH    R11,=H'2'               COND CODE = 2                    13990052
         BE    ARBP                    YES                              14000000
         CH    R11,=H'4'               COND CODE = 4                    14010052
         BE    ARBM                    YES                              14020000
         B     NOEXTND                 NO, NOT EXTENDED                 14030000
ARBZ     DS    0H                                                       14040045
         MVC   MNEMONIC(2),=C'BZ'      SET EXT MNEMONIC                 14050045
         B     BCXTFIN                 CONTINUE                         14060000
ARBNO    DS    0H                                                       14070045
         MVC   MNEMONIC(3),=C'BNO'     SET EXTENDED MNEMONIC            14080045
         B     BCXTFIN                 CONTINUE                         14090000
ARBNP    DS    0H                                                       14100045
         MVC   MNEMONIC(3),=C'BNP'     SET EXT MNEMONIC                 14110045
         B     BCXTFIN                 CONTINUE                         14120000
ARBNM    DS    0H                                                       14130045
         MVC   MNEMONIC(3),=C'BNM'     SET EXT MNEMONIC                 14140045
         B     BCXTFIN                 CONTINUE                         14150000
ARBNZ    DS    0H                                                       14160045
         MVC   MNEMONIC(3),=C'BNZ'     SET EXT MNEMONIC                 14170045
         B     BCXTFIN                 CONTINUE                         14180000
ARBO     DS    0H                                                       14190045
         MVC   MNEMONIC(2),=C'BO'      SET EXT MNEMONIC                 14200045
         B     BCXTFIN                 CONTINUE                         14210000
ARBP     DS    0H                                                       14220045
         MVC   MNEMONIC(2),=C'BP'      SET EXT MNEMONIC                 14230045
         B     BCXTFIN                 CONTINUE                         14240000
ARBM     DS    0H                                                       14250045
         MVC   MNEMONIC(2),=C'BM'      SET EXT MNEMONIC                 14260045
         B     BCXTFIN                 CONTINUE                         14270000
EXTZRO   DS    0H                                                       14280045
         CH    R11,=H'8'               COND CODE = 8                    14290052
         BE    ARBZ                    YES, USE BZ MNEMONIC             14300000
         CH    R11,=H'7'               COND CODE IS 7                   14310052
         BE    ARBNZ                   YES                              14320000
         B     NOEXTND                 NO, NOT EXTENDED                 14330000
EXTCPR   DS    0H                                                       14340045
         CH    R11,=H'8'               COND CODE = 8                    14350052
         BE    CPBE                    YES                              14360000
         CH    R11,=H'7'               COND CODE = 7                    14370052
         BE    CPBNE                   YES                              14380000
         BL    CPLOW                   NO, LOWER                        14390000
         CH    R11,=H'13'              COND CODE = 13                   14400052
         BE    CPBNH                   YES                              14410000
         CH    R11,=H'11'              COND CODE = 11                   14420052
         BE    CPBNL                   YES                              14430000
         B     NOEXTND                 NO, NOT EXTENDED                 14440000
CPLOW    DS    0H                                                       14450045
         CH    R11,=H'4'               COND CODE = 4                    14460052
         BE    CPBL                    YES                              14470000
         CH    R11,=H'2'               COND CODE = 2                    14480052
         BE    CPBH                    YES                              14490000
         B     NOEXTND                 NO, NOT EXTENDED                 14500000
CPBE     DS    0H                                                       14510045
         MVC   MNEMONIC(2),=C'BE'      SET EXT MNEMONIC                 14520045
         B     BCXTFIN                 CONTINUE                         14530000
CPBNE    DS    0H                                                       14540045
         MVC   MNEMONIC(3),=C'BNE'     SET EXT MNEMONIC                 14550045
         B     BCXTFIN                 CONTINUE                         14560000
CPBNH    DS    0H                                                       14570045
         MVC   MNEMONIC(3),=C'BNH'     SET EXT MNEMONIC                 14580045
         B     BCXTFIN                 CONTINUE                         14590000
CPBNL    DS    0H                                                       14600045
         MVC   MNEMONIC(3),=C'BNL'     SET EXT MNEMONIC                 14610045
         B     BCXTFIN                 CONTINUE                         14620000
CPBL     DS    0H                                                       14630045
         MVC   MNEMONIC(2),=C'BL'      SET EXT MNEMONIC                 14640045
         B     BCXTFIN                 CONTINUE                         14650000
CPBH     DS    0H                                                       14660045
         MVC   MNEMONIC(2),=C'BH'      SET EXTENDED MNEMONIC            14670045
         B     BCXTFIN                 CONTINUE                         14680000
******************************************************************      14690000
*                                                                *      14700000
* VALIDATE AND FORMAT SVC INSTRUCTIONS. IF THE SVC OP-CODE IS    *      14710000
* FOUND IN THE SVC TABLE, IT IS ACCEPTED AS AN SVC, AND THE TABLE*      14720000
* LITERAL IS MOVED TO THE COMMENTS FIELD OF THE INSTRUCTION.     *      14730000
*                                                                *      14740000
******************************************************************      14750000
SVCOPND  DS    0H                      *** SVC INSTRUCTIONS ***         14760036
         CLI   TEXT+1,126              VALID OPERAND                    14770000
         BH    NOTSVC                  NO, NOT SVC                      14780000
         L     R1,SVCTBLAD             GET SVC TABLE ADDRESS            14790000
SVCKND   DS    0H                                                       14800045
         CLI   0(R1),X'FF'             END OF SVC TABLE                 14810045
         BE    NOTSVC                  YES, MUST NOT BE SVC             14820000
         CLC   0(1,R1),TEXT+1          THIS THE ENTRY                   14830000
         BE    GOTSVC                  YES                              14840000
         LA    R1,L'SVCOP(,R1)         STEP TO NEXT ENTRY               14850036
         B     SVCKND                  LOOP THRU TABLE                  14860000
NOTSVC   DS    0H                                                       14870045
         B     4(,R9)                  ERROR RETURN                     14880045
GOTSVC   DS    0H                                                   DSK 14890017
         TM    PRMOPT,DBGNOCMT         Skip comments                DSK 14900017
         BO    NOCMT20                 Yes                          DSK 14910017
         MVC   COMMENT(14),1(R1)       COMMENT TO WORK AREA         DSK 14920017
NOCMT20  DS    0H                                                   DSK 14930017
         SR    R1,R1                   CLEAR WORK                       14940000
         IC    R1,TEXT+1               GET SVC OPERAND                  14950000
         CVD   R1,DBLWD                CONVERT                          14960000
         OI    DBLWD+7,X'0F'           CLEAR SIGN                       14970000
         UNPK  DBLWD(3),DBLWD+6(2)     UNPACK                           14980000
         CH    R1,=H'100'              OPERAND > 100                    14990052
         BL    SVCK10                  YES                              15000000
         MVC   OPNDS(3),DBLWD          MOVE 3-DIGIT OPERAND             15010000
         B     SVCXIT                  EXIT                             15020000
SVCK10   DS    0H                                                       15030045
         CH    R1,=H'10'               OPERAND < 10                     15040052
         BL    SVCL10                  YES                              15050000
         MVC   OPNDS(2),DBLWD+1        MOVE 2-DIGIT OPERAND             15060000
         B     SVCXIT                  EXIT                             15070000
SVCL10   DS    0H                                                       15080045
         MVC   OPNDS(1),DBLWD+2        MOVE 1-DIGIT OPERAND             15090045
SVCXIT   DS    0H                                                       15100045
         BR    R9                      EXIT                             15110045
******************************************************************      15120000
*                                                                *      15130036
* BUILD EQU STATEMENTS USING THE LABEL TABLE ENTRY ADDRESSED BY  *      15140000
* REG 6 ON ENTRY.                                                *      15150000
*                                                                *      15160000
******************************************************************      15170000
EQUSTMT  DS    0H                      BUILD EQU STATEMENTS             15180036
         ST    R9,EQU9                 SAVE RETURN ADDR                 15190000
         USING LABELD,R6                                                15200000
         MVC   NAME,LBLNAME            NAME TO EQU STMT                 15210037
         MVC   MNEMONIC,=CL5'EQU'      BUILD EQU STATEMENT              15220000
         TM    EQUOPFLG,X'80'          EQU operand type flag=offset DSK 15230036
         BNO   CCXAST                  Not use asterisk             DSK 15240036
         MVC   OPNDS(L'CSECT),CSECT    CSECT name                   DSK 15250036
         LA    R1,OPNDS                Start of operands            DSK 15260036
CCXOFF10 DS    0H                                                   DSK 15270036
         CLI   0(R1),C' '              Scan to end of CSECT name    DSK 15280036
         BE    CCXOFF20                At end                       DSK 15290036
         LA    R1,1(,R1)               Next character               DSK 15300036
         B     CCXOFF10                Keep looking                 DSK 15310036
CCXOFF20 DS    0H                                                   DSK 15320036
         MVC   0(3,R1),=C'+X'''        Set up offset                DSK 15330036
         UNPK  3(7,R1),LBLADR(4)       Get offset                   DSK 15340036
         TR    3(6,R1),TRTBL-240       Clean up hex digits          DSK 15350036
         MVI   9(R1),C''''             End of offset                DSK 15360036
         CLI   LBLLEN,1                Length 0 or 1                DSK 15370036
         BNH   CCXEQU                  Yes, skip length             DSK 15380036
         MVI   10(R1),C','             Seperate offset and length   DSK 15390036
         SR    R0,R0                   Clear                        DSK 15400036
         IC    R0,LBLLEN               Get length                   DSK 15410036
         CVD   R0,DBLWD                Convert                      DSK 15420036
         UNPK  DBLWD(3),DBLWD+6(2)     Unpack                       DSK 15430036
         OI    DBLWD+2,C'0'            Set s ign                    DSK 15440036
         CH    R0,=H'10'               More than 1 digit            DSK 15450052
         BL    CCXOFF30                No                           DSK 15460036
         MVC   11(2,R1),DBLWD+1        Move 2-digit length          DSK 15470036
         B     CCXEQU                  Done                         DSK 15480036
CCXOFF30 DS    0H                                                   DSK 15490036
         MVC   11(1,R1),DBLWD+2        Move 1-digit length          DSK 15500036
         B     CCXEQU                  Done                         DSK 15510036
CCXAST   DS    0H                                                   DSK 15520036
         MVI   OPNDS,C'*'              SET EQU OPERAND                  15530000
         CLI   LBLLEN,1                LENGTH 0 OR 1                    15540000
         BNH   CCXEQU                  YES                              15550000
         SR    R9,R9                   CLEAR WORK                       15560000
         IC    R9,LBLLEN               GET LENGTH                       15570000
         CVD   R9,DBLWD                CONVERT                          15580000
         UNPK  DBLWD(3),DBLWD+6(2)     UNPACK                           15590000
         OI    DBLWD+2,C'0'            CLEAR SIGN                       15600000
         CH    R9,=H'100'              LENGTH < 100                     15610052
         BL    CCXQ10                  YES                              15620000
         MVC   OPNDS+2(3),DBLWD        MOVE LENGTH                      15630000
         B     CCXEQC                  GO SET COMMA                     15640000
CCXQ10   DS    0H                                                       15650045
         CH    R9,=H'10'               LENGTH < 10                      15660052
         BL    CCXQ1                   YES                              15670000
         MVC   OPNDS+2(2),DBLWD+1      MOVE 2-DIGIT LENGTH              15680000
         B     CCXEQC                  GO SET COMMA                     15690000
CCXQ1    DS    0H                                                       15700045
         MVC   OPNDS+2(1),DBLWD+2      MOVE 1-DIGIT LENGTH              15710045
CCXEQC   DS    0H                                                       15720045
         MVI   OPNDS+1,C','            SET COMMA                        15730045
         B     CCXEQU                  Done                         DSK 15740037
*        Generate EQU for offset different tben current location    dsk 15750037
EQUDIFF  DS    0H                                                   DSK 15760037
         ST    R9,EQU9                 SAVE RETURN ADDR             DSK 15770037
         LR    R1,R7                   Instruction address          dsk 15780037
         S     R1,TXTSTRT              Less buffer start            dsk 15790037
         SR    R0,R0                   Clear                        dsk 15800037
         ICM   R0,7,LBLADR             Get this labels offseet      dsk 15810037
         SR    R0,R1                   Offset from current address  dsk 15820037
         CVD   R0,DBLWD                                             dsk 15830037
         MVC   NAME,LBLNAME            Name                         dsk 15840037
         MVC   MNEMONIC,=CL5'EQU'                                   dsk 15850037
         MVC   OPNDS(2),=C'*+'                                      dsk 15860037
         LTR   R0,R0                                                dsk 15870037
         BNM   EQUPLUS                                              dsk 15880037
         MVI   OPNDS+1,C'-'                                         dsk 15890037
EQUPLUS  DS    0H                                                   dsk 15900037
         UNPK  OPNDS+2(1),DBLWD+7(1)   Get offset                   dsk 15910037
         OI    OPNDS+2,C'0'                                         dsk 15920037
CCXEQU   DS    0H                                                   DSK 15930025
         TM    PRMOPT,DBGCONST         DEBUG(CONST)                 DSK 15940025
         BZ    NODBGEQU                No                           DSK 15950025
         MVC   WORKREC+53(3),=C'TY='                                DSK 15960035
         MVC   WORKREC+56(1),LBLTYP    Label type                   DSK 15970035
         MVC   WORKREC+58(2),=C'L='                                 DSK 15980035
         UNPK  WORKREC+60(3),LBLLEN(2) Length                       DSK 15990035
         TR    WORKREC+60(2),TRTBL-240                              DSK 16000035
         MVC   WORKREC+62(3),=C' A='  Address                       DSK 16010035
         UNPK  WORKREC+65(7),LBLADR(4)                              DSK 16020035
         TR    WORKREC+65(6),TRTBL-240                              DSK 16030035
         MVI   WORKREC+71,C' '                                      DSK 16040052
NODBGEQU DS    0H                                                   DSK 16050025
         BAL   R9,WRTOUT               OUTPUT EQU STATEMENT         DSK 16060025
         BAL   R9,PRINT                GO PRINT IT                      16070000
         L     R9,EQU9                 GET RETURN ADDR                  16080000
         BR    R9                      RETURN                           16090000
         DROP  R6                                                       16100000
******************************************************************      16110000
*                                                                *      16120000
* BUILDS STORAGE OPERANDS CONTAINING BASE, DISPLACEMENT, AND     *      16130000
* LENGTH. ON ENTRY, REG 11 CONTAINS THE BDDD ADDRESS, AND REG 10 *      16140000
* CONTAINS THE LENGTH. THE SCHLBL ROUTINE IS CALLED TO CREATE A  *      16150000
* LABEL REFERENCE, IF THE BASE REG IS CURRENT, AND A LABEL EXISTS*      16160000
* IF SCHLBL IS UNSUCCESSFUL, AN EXPLICIT ADDRESS OF THE FORM     *      16170000
* DDDD(LLL,RRR) IS CREATED.                                      *      16180000
*                                                                *      16190000
******************************************************************      16200000
BDLADR   DS    0H                      *** FORMAT DDDD(LLL,RRR) OPERAND 16210036
         ST    R9,BDL9                 SAVE RETURN ADDR                 16220000
         SR    R0,R0                   CLEAR WORK REG                   16230000
         LR    R1,R11                  COPY BDDD ADDRESS                16240000
         SLDL  R0,20                   BASE REG TO R0                   16250000
         LTR   R0,R0                   IS BASE REG 0                    16260000
         BNZ   BDLSCHL                 NO                               16270000
         SRL   R1,20                   RIGHT JUSTIFY DISPL              16280000
         CH    R1,=H'16'               REFERENCE TO CVT ADDR            16290052
         BE    BDLCVTR                 YES                              16300000
         CH    R1,=H'76'               REF TO ALTERNATE CVT ADDR        16310052
         BE    BDLCVTR                 YES                              16320000
*        TM    PRMOPT,DBGNOCMT         Skip comments               DSK1 16330028
*        BO    NOCMT22                 Yes                         DSK1 16340028
*        MVC   COMMENT(13),=C'PSA REFERENCE'                       DSK1 16350028
NOCMT22  DS    0H                                                   DSK 16360017
         B     BDLSCHL                 CONTINUE                         16370000
BDLCVTR  DS    0H                                                   DSK 16380017
*        TM    PRMOPT,DBGNOCMT         Skip comments               DSK1 16390028
*        BO    NOCMT24                 Yes                         DSK1 16400028
*        MVC   COMMENT(11),=C'CVT ADDRESS'                         DSK1 16410028
NOCMT24  DS    0H                                                   DSK 16420017
BDLSCHL  DS    0H                                                       16430045
         BAL   R9,SCHLBL               SEARCH FOR LABEL                 16440045
         B     BDLGLBL                 BRANCH IF LABEL FOUND            16450000
         LR    R1,R11                  COPY BDDD ADDRESS                16460000
         SLL   R1,20                   SHIFT OUT B                      16470000
         SRL   R1,20                   RIGHT JUSTIFY DDD                16480000
         CVD   R1,DBLWD                CONVERT DDD                      16490000
         OI    DBLWD+7,X'0F'           CLEAR SIGN                       16500000
         UNPK  DBLWD(4),DBLWD+5(3)     UNPACK                           16510000
         MVC   OPNDWK,BLANX            CLEAR WORK AREA                  16520000
         CH    R1,=H'1000'             DISPL < 1000                     16530052
         BL    BDLD100                 YES                              16540000
         MVC   OPNDWK(4),DBLWD         MOVE 4-DIGIT DISPL               16550000
         LA    R1,OPNDWK+4             TO NEXT POS                      16560000
         B     BDLLPN                  CONTINUE                         16570000
BDLD100  DS    0H                                                       16580045
         CH    R1,=H'100'              DISPL < 100                      16590052
         BL    BDLD10                  YES                              16600000
         MVC   OPNDWK(3),DBLWD+1       MOVE 3-DIGIT DISPL               16610000
         LA    R1,OPNDWK+3             TO NEXT POS                      16620000
         B     BDLLPN                  CONTINUE                         16630000
BDLD10   DS    0H                                                       16640045
         CH    R1,=H'10'               DISPL < 10                       16650052
         BL    BDLD1                   YES                              16660000
         MVC   OPNDWK(2),DBLWD+2       MOVE 2-DIGIT DISPL               16670000
         LA    R1,OPNDWK+2             TO NEXT POS                      16680000
         B     BDLLPN                  CONTINUE                         16690000
BDLD1    DS    0H                                                       16700045
         MVC   OPNDWK(1),DBLWD+3       MOVE 1-DIGIT DISPL               16710045
         LA    R1,OPNDWK+1             TO NEXT POS                      16720000
BDLLPN   DS    0H                                                       16730045
         MVI   0(R1),C'('              LEFT PAREN DELIMITER             16740045
         LA    R10,1(,R10)             COMPUTE ACTUAL LENGTH FROM LENG  16750036
         CVD   R10,DBLWD               CONVERT                          16760000
         OI    DBLWD+7,X'0F'           CLEAR SIGN                       16770000
         UNPK  DBLWD(3),DBLWD+6(2)     UNPACK                           16780000
         CH    R10,=H'100'             LENGTH < 100                     16790052
         BL    BDLL10                  YES                              16800000
         MVC   1(3,R1),DBLWD           MOVE 3-DIGIT LENGTH              16810000
         LA    R1,4(,R1)               TO NEXT POS                      16820036
         B     BDLCMA                  CONTINUE                         16830000
BDLL10   DS    0H                                                       16840045
         CH    R10,=H'10'              LENGTH < 10                      16850052
         BL    BDLL1                   YES                              16860000
         MVC   1(2,R1),DBLWD+1         MOVE 2-DIGIT LENGTH              16870000
         LA    R1,3(,R1)               TO NEXT POS                      16880036
         B     BDLCMA                  CONTINUE                         16890000
BDLL1    DS    0H                                                       16900045
         MVC   1(1,R1),DBLWD+2         MOVE 1-DIGIT LENGTH              16910045
         LA    R1,2(,R1)               TO NEXT POS                      16920036
BDLCMA   DS    0H                                                       16930045
         MVC   0(2,R1),=C',R'          DELIMITERS                       16940045
         SRL   R11,12                  RT JUSTIFY BASE REG              16950000
         CVD   R11,DBLWD               CONVERT                          16960000
         OI    DBLWD+7,X'0F'           CLEAR SIGN                       16970000
         UNPK  DBLWD(2),DBLWD+6(2)     UNPACK                           16980000
         CH    R11,=H'10'              REG < 10                         16990052
         BL    BDLR1                   YES                              17000000
         MVC   2(2,R1),DBLWD           MOVE 2-DIGIT REGISTER            17010000
         LA    R1,4(,R1)               TO NEXT POS                      17020036
         B     BDLRPN                  CONTINUE                         17030000
BDLR1    DS    0H                                                       17040045
         MVC   2(1,R1),DBLWD+1         MOVE 1-DIGIT REG                 17050045
         CLI   2(R1),C'0'              IS REG = 0                       17060000
         BNE   BDLB1                   NO                               17070000
         MVC   0(2,R1),BLANX           YES, BLANK IT                    17080000
***      BCTR  R1,R0                   BACK UP 1            FIX***      17090000
         B     BDLRPN                  CONTINUE                         17100000
BDLB1    DS    0H                                                       17110045
         LA    R1,3(,R1)               TO NEXT POS                      17120045
BDLRPN   DS    0H                                                       17130045
         MVI   0(R1),C')'              FINAL DELIMITER                  17140045
         LR    R10,R1                  COPY END ADDRESS                 17150000
         S     R10,OWSTRT              COMPUTE OPERAND LENGTH CODE      17160000
         L     R9,BDL9                 GET RETURN ADDR                  17170000
         BR    R9                      EXIT                             17180000
         USING LABELD,R12                                               17190000
BDLGLBL  DS    0H                                                       17200045
         MVC   OPNDWK(8),LBLNAME       LABEL ENTRY NAME TO WORK         17210045
         LA    R10,1(,R10)             COMPUTE ACTUAL LENGTH            17220036
         LA    R1,OPNDWK+7             @ LAST POSS CHARACTER            17230000
BDLGRHE  DS    0H                                                       17240045
         CLI   0(R1),C' '              AT RHE                           17250045
         BNE   BDLGCKLN                YES                              17260000
         BCT   R1,BDLGRHE              LOOP TO RHE                      17270000
BDLGCKLN DS    0H                                                       17280045
         CLM   R10,1,LBLLEN            LBL AND INSTR LENGTHS SAME       17290045
         BE    BDLGCMP                 YES                              17300000
         MVI   1(R1),C'('              NO, DELIMITER                    17310000
         CVD   R10,DBLWD               CONVERT LENGTH                   17320000
         UNPK  DBLWD(3),DBLWD+5(3)     UNPACK                           17330000
         OI    DBLWD+2,C'0'            CLEAR SIGN                       17340000
         CH    R10,=H'100'             LENGTH < 100                     17350052
         BL    BDLG10                  YES                              17360000
         MVC   2(3,R1),DBLWD           MOVE 3-DIGIT LENGTH              17370000
         LA    R1,5(,R1)               TO NEXT POS                      17380036
         B     BDLGRPN                 CONTINUE                         17390000
BDLG10   DS    0H                                                       17400045
         CH    R10,=H'10'              LENGTH < 10                      17410052
         BL    BDLG1                   YES                              17420000
         MVC   2(2,R1),DBLWD+1         MOVE 2-DIGIT LENGTH              17430000
         LA    R1,4(,R1)               TO NEXT POS                      17440036
         B     BDLGRPN                 CONTINUE                         17450000
BDLG1    DS    0H                                                       17460045
         MVC   2(1,R1),DBLWD+2         MOVE 1-DIGIT LENGTH              17470045
         LA    R1,3(,R1)               TO NEXT POS                      17480036
BDLGRPN  DS    0H                                                       17490045
         MVI   0(R1),C')'              FINAL DELIMITER                  17500045
BDLGCMP  DS    0H                                                       17510045
         LR    R10,R1                  COPY END ADDRESS                 17520045
         S     R10,OWSTRT              COMPUTE LENGTH CODE              17530000
         L     R12,SLSAV+12            RESTORE R12                      17540000
         L     R9,BDL9                 GET RETURN ADDR                  17550000
         BR    R9                      EXIT                             17560000
         DROP  R12                                                      17570000
******************************************************************      17580000
*                                                                *      17590000
* BUILDS STORAGE OPERANDS CONTAINING BASE AND DISPLACEMENT.      *      17600000
* THE SCHLBL ROUTINE IS CALLED TO SEE WHETHER A LABEL REFERENCE  *      17610000
* MAY BE USED, RATHER THAN AN EXPLICIT ADDRESS. IF LBLSCH IS NOT *      17620000
* SUCCESSFUL, AN EXPLICIT ADDRESS OF THE FORM DDDD(RRR) IS FORMED*      17630000
* ON ENTRY, REG 11 CONTAINS THE BDDD ADDRESS.                    *      17640000
*                                                                *      17650000
******************************************************************      17660000
BDADR    DS    0H                      *** FORMAT DDDD(RRR) OPERANDS ** 17670036
         ST    R9,BD9                  SAVE RETURN ADDR                 17680000
         SR    R0,R0                   CLEAR WORK REG                   17690000
         LR    R1,R11                  COPY BDDD ADDRESS                17700000
         SLDL  R0,20                   BASE REG TO R0                   17710000
         LTR   R0,R0                   IS BASE REG 0                    17720000
         BNZ   BDSCHL                  NO                               17730000
         CLI   TEXT,X'8F'              IS IT SLDA??              FIX*** 17740000
         BH    BDSADR1                 YES                       FIX*** 17750000
         CLI   TEXT,X'88'              IS IT SRL                 FIX*** 17760000
         BNL   BDSCHL                  YES                       FIX*** 17770000
BDSADR1  DS    0H                                                       17780045
         SRL   R1,20                   RIGHT JUSTIFY DISPL       FIX*** 17790045
         CH    R1,=H'16'               REFERENCE TO CVT ADDR            17800052
         BE    BDCVTR                  YES                              17810000
         CH    R1,=H'76'               REF TO ALTERNATE CVT ADDR        17820052
         BE    BDCVTR                  YES                              17830000
*        TM    PRMOPT,DBGNOCMT         Skip comments               DSK1 17840028
*        BO    NOCMT26                 Yes                         DSK1 17850028
*        MVC   COMMENT(13),=C'PSA REFERENCE'                       DSK1 17860028
NOCMT26  DS    0H                                                   DSK 17870017
         B     BDSCHL                  CONTINUE                         17880000
BDCVTR   DS    0H                                                   DSK 17890017
*        TM    PRMOPT,DBGNOCMT         Skip comments               DSK1 17900028
*        BO    NOCMT28                 Yes                         DSK1 17910028
*        MVC   COMMENT(11),=C'CVT ADDRESS'                         DSK1 17920028
NOCMT28  DS    0H                                                   DSK 17930017
BDSCHL   DS    0H                                                       17940045
         BAL   R9,SCHLBL               GO SEARCH FOR LABEL              17950045
         B     BDGLBL                  BRANCH IF FOUND                  17960000
         LR    R1,R11                  COPY BDDD ADDRESS                17970000
         SLL   R1,20                   SHIFT OUT B                      17980000
         SRL   R1,20                   RIGHT JUSTIFY DDD                17990000
         CVD   R1,DBLWD                CONVERT DISPL                    18000000
         OI    DBLWD+7,X'0F'           CLEAR SIGN                       18010000
         UNPK  DBLWD(4),DBLWD+5(3)     UNPACK                           18020000
         CH    R1,=H'1000'             DISPL < 1000                     18030052
         BL    BDAD100                 YES                              18040000
         MVC   OPNDWK(4),DBLWD         MOVE 4-DIGIT DISPL               18050000
         LA    R1,OPNDWK+4             TO NEXT POS                      18060000
         B     BDALPN                  CONTINUE                         18070000
BDAD100  DS    0H                                                       18080045
         CH    R1,=H'100'              DISPL < 100                      18090052
         BL    BDAD10                  YES                              18100000
         MVC   OPNDWK(3),DBLWD+1       MOVE 3-DIGIT DISPL               18110000
         LA    R1,OPNDWK+3             TO NEXT POS                      18120000
         B     BDALPN                  CONTINUE                         18130045
BDAD10   DS    0H                                                       18140045
         CH    R1,=H'10'               DISPL < 10                       18150052
         BL    BDAD1                   YES                              18160000
         MVC   OPNDWK(2),DBLWD+2       MOVE 2-DIGIT DISPL               18170000
         LA    R1,OPNDWK+2             TO NEXT POS                      18180000
         B     BDALPN                  CONTINUE                         18190000
BDAD1    DS    0H                                                       18200045
         MVC   OPNDWK(1),DBLWD+3       MOVE 1-DIGIT DISPL               18210045
         LA    R1,OPNDWK+1             TO NEXT POS                      18220000
BDALPN   DS    0H                                                       18230045
         MVC   0(2,R1),=C'(R'          DELIMITERS                       18240045
         SRL   R11,12                  RT JUSTIFY BASE REG              18250000
         CVD   R11,DBLWD               CONVERT                          18260000
         OI    DBLWD+7,X'0F'           CLEAR SIGN                       18270000
         UNPK  DBLWD(2),DBLWD+6(2)     UNPACK                           18280000
         CH    R11,=H'10'              BASE REG < 10                    18290052
         BL    BDAR1                   YES                              18300000
         MVC   2(2,R1),DBLWD           MOVE 2-DIGIT BASE REG            18310000
         LA    R1,4(,R1)               TO NEXT POS                      18320036
         B     BDARPN                  CONTINUE                         18330000
BDAR1    DS    0H                                                       18340045
         MVC   2(1,R1),DBLWD+1         MOVE 1-DIGIT BASE REG            18350045
         LA    R1,3(,R1)               TO NEXT POS                      18360036
BDARPN   DS    0H                                                       18370045
         MVI   0(R1),C')'              FINAL DELIMITER                  18380045
         LR    R2,R1                   COPY END ADDRESS                 18390000
         SH    R2,=H'4'                BACK UP 4                        18400052
         CLC   1(4,R2),=C'(R0)'        BASE REG IS ZERO                 18410000
         BNE   BDCE                    NO                               18420000
         MVC   1(4,R2),BLANX           CLEAR BASE REG                   18430000
         LR    R1,R2                   COPY NEW END ADDR                18440000
BDCE     DS    0H                                                       18450045
         LR    R10,R1                  COPY END ADDR                    18460045
         S     R10,OWSTRT              COMPUTE LENGTH CODE              18470000
         L     R9,BD9                  GET RETURN ADDR                  18480000
         BR    R9                      EXIT                             18490000
         USING LABELD,R12                                               18500000
BDGLBL   DS    0H                                                       18510045
         MVC   OPNDWK(8),LBLNAME       LABEL ENTRY NAME TO WORK         18520045
         LA    R1,OPNDWK+7             @ LAST POSS CHARACTER            18530000
BDGRHE   DS    0H                                                       18540045
         CLI   0(R1),C' '              AT RHE                           18550045
         BNE   BDGCMP                  YES                              18560000
         BCT   R1,BDGRHE               LOOP TO RHE                      18570000
BDGCMP   DS    0H                                                       18580045
         LR    R10,R1                  COPY END ADDRESS                 18590045
         S     R10,OWSTRT              COMPUTE LENGTH CODE              18600000
         L     R12,SLSAV+12            RESTORE R12                      18610000
         L     R9,BD9                  GET RETURN ADDR                  18620000
         BR    R9                      EXIT                             18630000
******************************************************************      18640000
*                                                                *      18650000
* BUILDS STORAGE OPERANDS CONTAINING BASE, DISPLACEMENT, AND     *      18660000
* INDEX. ON ENTRY, REG 11 CONTAINS THE BDDD ADDRESS, AND REG 10  *      18670000
* CONTAINS THE INDEX. THE SCHLBL ROUTINE IS CALLED TO CREATE A   *      18680000
* LABEL REFERENCE, IF THE BASE REG IS CURRENT, AND A LABEL EXISTS*      18690000
* IF SCHLBL IS UNSUCCESSFUL, AN EXPLICIT ADDRESS OF THE FORM     *      18700000
* DDDD(XXX,RRR) IS CREATED.                                      *      18710000
*                                                                *      18720000
******************************************************************      18730000
BDXADR   DS    0H                      *** FORMAT DDDD(XXX,BBB) OPERAND 18740036
         ST    R9,BDX9                 SAVE RETURN ADDR                 18750000
         LTR   R10,R10                 ANY INDEX REG                    18760000
         BNZ   BDXSCHL                 YES                              18770000
         SR    R0,R0                   CLEAR WORK REG                   18780000
         LR    R1,R11                  COPY BDDD ADDRESS                18790000
         SLDL  R0,20                   BASE REG TO R0                   18800000
         LTR   R0,R0                   IS BASE REG 0                    18810000
         BNZ   BDXSCHL                 NO                               18820000
         CLI   TEXT,X'41'              IS IT LA                         18830000
         BE    BDXSCHL                 YES                              18840000
         SRL   R1,20                   RIGHT JUSTIFY DISPL              18850000
         CH    R1,=H'16'               REFERENCE TO CVT ADDR            18860052
         BE    BDXCVTR                 YES                              18870000
         CH    R1,=H'76'               REF TO ALTERNATE CVT ADDR        18880052
         BE    BDXCVTR                 YES                              18890000
*        TM    PRMOPT,DBGNOCMT         Skip comments               DSK1 18900028
*        BO    NOCMT30                 Yes                         DSK1 18910028
*        MVC   COMMENT(13),=C'PSA REFERENCE'                       DSK1 18920028
NOCMT30  DS    0H                                                   DSK 18930017
         B     BDXSCHL                 CONTINUE                         18940000
BDXCVTR  DS    0H                                                   DSK 18950017
*        TM    PRMOPT,DBGNOCMT         Skip comments               DSK1 18960028
*        BO    NOCMT32                 Yes                         DSK1 18970028
*        MVC   COMMENT(11),=C'CVT ADDRESS'                         DSK1 18980028
NOCMT32  DS    0H                                                   DSK 18990017
BDXSCHL  DS    0H                                                       19000045
         BAL   R9,SCHLBL               GO SEARCH FOR LABEL              19010045
         B     BDXGLBL                 BRANCH IF FOUND                  19020000
         LR    R1,R11                  COPY BDDD ADDRESS                19030000
         SLL   R1,20                   SHIFT OUT BASE REG               19040000
         SRL   R1,20                   RIGHT JUSTIFY DISPL              19050000
         SRL   R11,12                  RT JUSTIFY BASE REG              19060000
         CVD   R1,DBLWD                CONVERT                          19070000
         OI    DBLWD+7,X'0F'           CLEAR SIGN                       19080000
         UNPK  DBLWD(4),DBLWD+5(3)     UNPACK                           19090000
         CH    R1,=H'1000'             DISPL < 1000                     19100052
         BL    BDXD100                 YES                              19110000
         MVC   OPNDWK(4),DBLWD         MOVE 4-DIGIT DISPL               19120000
         LA    R1,OPNDWK+4             TO NEXT POS                      19130000
         B     BDXLPN                  CONTINUE                         19140000
BDXD100  DS    0H                                                       19150045
         CH    R1,=H'100'              DISPL < 100                      19160052
         BL    BDXD10                  YES                              19170000
         MVC   OPNDWK(3),DBLWD+1       MOVE 3-DIGIT DISPL               19180000
         LA    R1,OPNDWK+3             TO NEXT POS                      19190000
         B     BDXLPN                  CONTINUE                         19200000
BDXD10   DS    0H                                                       19210045
         CH    R1,=H'10'               DISPL < 10                       19220052
         BL    BDXD1                   YES                              19230000
         MVC   OPNDWK(2),DBLWD+2       MOVE 2-DIGIT DISPL               19240000
         LA    R1,OPNDWK+2             TO NEXT POS                      19250000
         B     BDXLPN                  CONTINUE                         19260000
BDXD1    DS    0H                                                       19270045
         MVC   OPNDWK(1),DBLWD+3       MOVE 1-DIGIT DISPL               19280045
         LA    R1,OPNDWK+1             TO NEXT POS                      19290000
BDXLPN   DS    0H                                                       19300045
         LTR   R10,R10                 ANY INDEX REG                    19310045
         BNZ   BDXLPNR                 YES                              19320000
         LTR   R11,R11                 ANY BASE REG                     19330000
         BNZ   PREPB                   YES                              19340000
         BCTR  R1,R0                   NO, BACK UP TO RHE               19350000
         B     BDXCE                   CONTINUE                         19360000
PREPB    DS    0H                                                       19370045
         MVC   0(3,R1),=C'(,R'         DELIMITERS                       19380045
         LA    R1,1(,R1)               STEP OVER 1 BYTE                 19390036
         B     BDXCBAS                 CONTINUE                         19400000
BDXLPNR  DS    0H                                                       19410045
         MVC   0(2,R1),=C'(R'          DELIMITERS                       19420045
         CVD   R10,DBLWD               CONVERT INDEX REG                19430000
         OI    DBLWD+7,X'0F'           CLEAR SIGN                       19440000
         UNPK  DBLWD(2),DBLWD+6(2)     UNPACK                           19450000
         CH    R10,=H'10'              INDEX REG < 10                   19460052
         BL    BDXX1                   YES                              19470000
         MVC   2(2,R1),DBLWD           MOVE 2-DIGIT INDEX REG           19480000
         LA    R1,4(,R1)               TO NEXT POS                      19490036
         B     BDXCMA                  CONTINUE                         19500000
BDXX1    DS    0H                                                       19510045
         MVC   2(1,R1),DBLWD+1         MOVE 1-DIGIT INDEX REG           19520045
         LA    R1,3(,R1)               TO NEXT POS                      19530036
BDXCMA   DS    0H                                                       19540045
         LTR   R11,R11                 ANY BASE REG                     19550045
         BZ    BDXRPN                  NO                               19560000
         MVC   0(2,R1),=C',R'          DELIMITERS                       19570000
BDXCBAS  DS    0H                                                       19580045
         CVD   R11,DBLWD               CONVERT                          19590045
         OI    DBLWD+7,X'0F'           CLEAR SIGN                       19600000
         UNPK  DBLWD(2),DBLWD+6(2)     UNPACK                           19610000
         CH    R11,=H'10'              BASE REG < 10                    19620052
         BL    BDXB1                   YES                              19630000
         MVC   2(2,R1),DBLWD           MOVE 2-DIGIT BASE REG            19640000
         LA    R1,4(,R1)               TO NEXT POS                      19650036
         B     BDXRPN                  CONTINUE                         19660000
BDXB1    DS    0H                                                       19670045
         MVC   2(1,R1),DBLWD+1         MOVE 1-DIGIT BASE REG            19680045
         LA    R1,3(,R1)               TO NEXT POS                      19690036
BDXRPN   DS    0H                                                       19700045
         MVI   0(R1),C')'              FINAL DELIMITER                  19710045
BDXCE    DS    0H                                                       19720045
         LR    R10,R1                  COPY END ADDR                    19730045
         S     R10,OWSTRT              COMPUTE LENGTH CODE              19740000
         L     R9,BDX9                 GET RETURN ADDR                  19750000
         BR    R9                      EXIT                             19760000
         USING LABELD,R12                                               19770000
BDXGLBL  DS    0H                                                       19780045
         MVC   OPNDWK(8),LBLNAME       LABEL ENTRY NAME TO WORK         19790045
         LA    R1,OPNDWK+7             @ LAST POSS CHARACTER            19800000
BDXGRHE  DS    0H                                                       19810045
         CLI   0(R1),C' '              AT RHE                           19820045
         BNE   BDXGCKLN                YES                              19830000
         BCT   R1,BDXGRHE              LOOP TO RHE                      19840000
BDXGCKLN DS    0H                                                       19850045
         LTR   R10,R10                 ANY INDEX REGISTER               19860045
         BZ    BDXGCMP                 NO                               19870000
         MVI   1(R1),C'('              YES, DELIMITER                   19880000
         CVD   R10,DBLWD               CONVERT LENGTH                   19890000
         UNPK  DBLWD(2),DBLWD+6(2)     UNPACK                           19900000
         OI    DBLWD+1,C'0'            CLEAR SIGN                       19910000
BDXG10   DS    0H                                                       19920045
         CH    R10,=H'10'              LENGTH < 10                      19930052
         BL    BDXG1                   YES                              19940000
         MVC   2(2,R1),DBLWD           MOVE 2-DIGIT LENGTH              19950000
         LA    R1,4(,R1)               TO NEXT POS                      19960036
         B     BDXGRPN                 CONTINUE                         19970000
BDXG1    DS    0H                                                       19980045
         MVC   2(1,R1),DBLWD+1         MOVE 1-DIGIT LENGTH              19990045
         LA    R1,3(,R1)               TO NEXT POS                      20000036
BDXGRPN  DS    0H                                                       20010045
         MVI   0(R1),C')'              FINAL DELIMITER                  20020045
BDXGCMP  DS    0H                                                       20030045
         LR    R10,R1                  COPY END ADDRESS                 20040045
         S     R10,OWSTRT              COMPUTE LENGTH CODE              20050000
         L     R12,SLSAV+12            RESTORE R12                      20060000
         L     R9,BDX9                 GET RETURN ADDR                  20070000
         BR    R9                      EXIT                             20080000
*                                                                       20090000
*                                                                       20100000
*                                                                       20110000
WRTOUT   DS    0H                      WRITE OUTPUT RECORDS             20120035
         AP    CARDNO,=P'10'           INCREMENT CARD NO                20130000
         UNPK  SEQNBR,CARDNO           UNPACK INTO CARD                 20140000
         OI    SEQNBR+7,C'0'           CLEAR SIGN                       20150000
         TM    PRMOPT,DBGINSTR         DEBUG(INSTR)                 DSK 20160016
         BZ    NOHEXDT                 No                           DSK 20170016
         CLC   WORKREC+52(20),BLANX    IF LITERAL/COMMENTS HERE     DSK 20180046
         BNE   NOHEXDT                 SKIP MOVING HEX INSTR/DATA   DSK 20190016
         MVC   WORKREC+53(4),PRT+83    COPY OFFSET                  DSK 20200035
         MVC   WORKREC+58(12),PRT+91   COPY INSTRUCTION/DATA        DSK 20210035
NOHEXDT  DS    0H                                                   DSK 20220016
         MVC   PRT(80),WORKREC         SAVE IN PRINT                DSK 20230035
         L     R1,PUNCHDCB             @ SYSPUNCH DCB               dsk 20240035
         TM    48(R1),X'10'            IS FILE OPEN                 DSK 20250035
         BZ    CLRWKR                  NO                           DSK 20260035
         PUT   (1),WORKREC             WRITE SOURCE CARD                20270000
CLRWKR   DS    0H                                                       20280045
         MVC   WORKREC,BLANX           CLEAR OUTPUT RECORD              20290045
         BR    R9                      RETURN                           20300000
******************************************************************      20310000
*                                                                *      20320000
* SEARCHES THE BASE REGISTER TABLE TO FIND THE BASE REGISTER     *      20330000
* ASSOCIATED WITH THE BDDD OPERAND ADDRESS PASSED IN REG 11 ON   *      20340000
* ENTRY. IF THE BASE REGISTER GIVEN IS NOT A CURRENT BASE REG    *      20350000
* THE UNSUCCESSFUL RETURN IS MADE TO 4 BYTES PAST THE ADDRESS    *      20360000
* IN REG 9 ON ENTRY. WHEN THE CURRENT BASE REGISTER ENTRY IS FOR *      20370000
* A PROGRAM BASE REG, THE DISPLACEMENT IS ADDED TO THE ASSUMED   *      20380000
* BASE REGISTER VALUE IS ADDED TO THE DISPLACEMENT TO GIVE AN    *      20390000
* OFFSET IN THE PROGRAM. THE LABEL TABLE IS SEARCHED FOR AN ENTRY*      20400000
* WITH THIS OFFSET, AND IF FOUND, IS RETURNED TO THE CALLER. WHEN*      20410000
* THE BASE REGISTER FOUND IS FOR A DSECT, THE DSECT HEADER ENTRY *      20420000
* ADDRESS IS GIVEN IN THE BASE TABLE ENTRY. THE DSECT HEADER HAS *      20430000
* THE ADDRESS OF THE FIELD DEFINITION TABLE FOR THE DSECT. THE   *      20440000
* FIELD DEFINITION TABLE IS SEARCHED FOR AN ENTRY HAVING THE     *      20450000
* DISPLACEMENT IN THE BDDD INSTRUCTION, AND IF FOUND IS PASSED   *      20460000
* BACK TO THE CALLER. IF THE LABEL/FIELD TABLE SEARCHES ARE      *      20470000
* UNSUCCESSFUL, RETURN IS TO 4 BYTES PAST REG 9.                 *      20480000
*                                                                *      20490000
******************************************************************      20500000
SCHLBL   DS    0H                      *** SEARCH FOR LABEL AT BDDD ADD 20510036
         TM    MORUSG,X'80'            ANY BASES ACTIVE                 20520000
         BZ    4(,R9)                  NO, UNSUCCESSFUL EXIT            20530036
         STM   R9,R12,SLSAV            YES, SAVE REGS USED              20540000
         LR    R12,R11                 COPY BDDD ADDRESS                20550000
         SRL   R12,12                  CLEAR WORK REG                   20560000
         LTR   R12,R12                 IS BASE REG ZERO                 20570000
         BZ    SCHNF                   YES, NO LABEL                    20580000
         MH    R12,USGLEN              BASE X BASE TBL ENTRY LENG       20590000
         LA    R12,BASES(R12)          @ BASE TBL ENTRY                 20600000
         USING USINGD,R12                                               20610000
         CLI   USTYPE,0                ENTRY IN USE                     20620000
         BE    SCHNF                   NO, EXIT                         20630000
         LR    R9,R11                  COPY BDDD ADDRESS                20640000
         SLL   R9,20                   SHIFT OUT BASE                   20650000
         SRL   R9,20                   RIGHT JUSTIFY DDD                20660000
         ICM   R11,7,USVALU            GET BASE REG VALUE               20670000
         LA    R11,0(,R11)             CLEAR HI-ORDER                   20680036
         CLI   USTYPE,C'P'             PROGRAM BASE REG                 20690000
         BE    PGMBASE                 YES                              20700000
         DROP  R12                                                      20710000
         LR    R12,R11                 COPY DSECT FIELD TBL ADDRESS     20720000
         USING DSECTD,R12                                               20730000
CKDSCTND DS    0H                                                       20740045
         CLM   R9,7,DSOFSET            THIS THE ENTRY                   20750045
         BE    SCHFD                   YES                              20760000
         CLC   DSOFSET,HIVAL           NO, AT TABLE END                 20770000
         BE    SCHNF                   YES, NO LABEL FOUND              20780000
         LA    R12,L'DSECT(,R12)       STEP TO NEXT ENTRY               20790036
         B     CKDSCTND                LOOP THRU DSECT FIELDS           20800000
PGMBASE  DS    0H                                                       20810045
         AR    R9,R11                  COMPUTE OFFSET                   20820045
         DROP  R12                                                      20830000
         L     R12,LBLTBL              @ LABEL TABLE                    20840000
         USING LABELD,R12                                               20850000
CKENTFD  DS    0H                                                       20860045
         CLM   R9,7,LBLADR             THIS THE ENTRY                   20870045
         BE    SCHFD                   YES                              20880000
         LA    R12,L'LABEL(,R12)       TO NEXT ENTRY                    20890036
         C     R12,CURRLBL             END OF TBL                       20900000
         BNL   SCHNF                   YES, NO LABEL                    20910000
         B     CKENTFD                 NO, CONTINUE SEARCH              20920000
SCHNF    DS    0H                                                       20930045
         LM    R9,R12,SLSAV            NOT FOUND, RESTORE REGS          20940045
         B     4(,R9)                  NOT FOUND RETURN                 20950036
SCHFD    DS    0H                                                       20960045
         LM    R9,R11,SLSAV            FOUND RESTORE ALL BUT 12         20970045
         BR    R9                      FOUND RETURN                     20980000
         DROP  R12                                                      20990000
******************************************************************      21000000
*                                                                *      21010000
* PRINT A LINE USING THE SYSPRINT DCB DEFINED IN DISASM PHASE 0. *      21020000
*                                                                *      21030000
******************************************************************      21040000
PRINT    DS    0H                      PRINT ROUTINE                    21050036
         L     R1,PRINTDCB             @ SYSPRINT DCB                   21060000
         TM    48(R1),X'10'            IS SYSPRINT OPEN                 21070000
         BNO   CLRPRT                  NO                               21080000
         PUT   (1),PRTLINE             WRITE PRINT LINE                 21090000
CLRPRT   DS    0H                                                       21100045
         MVC   PRT,BLANX               CLEAR PRINT LINE                 21110045
         AP    LINECT,=P'1'            INCR LINE COUNTER                21120052
         CLI   PCC,C' '                SINGLE SPACED                    21130000
         BE    SETSGL                  YES                              21140000
         AP    LINECT,=P'1'            INCR LINE COUNTER                21150052
         CLI   PCC,C'0'                DOUBLE SPACED                    21160000
         BE    SETSGL                  YES                              21170000
         AP    LINECT,=P'1'            INCR LINE COUNTER                21180052
         CLI   PCC,C'-'                TRIPLE SPACED                    21190000
         BE    SETSGL                  YES                              21200000
         ZAP   LINECT,=P'0'            NO, MUST BE NEW PAGE             21210052
SETSGL   DS    0H                                                       21220045
         MVI   PCC,C' '                SET SINGLE SPACING               21230045
         CP    LINECT,=P'58'           PAST END OF PAGE                 21240052
         BH    NEWPAGE                 YES                              21250000
         BR    R9                      EXIT                             21260000
NEWPAGE  DS    0H                                                       21270045
         MVI   PCC,C'1'                SET SKIP TO HOF                  21280045
         ZAP   LINECT,=P'0'            RESET LINE COUNTER               21290052
         BR    R9                      EXIT                             21300000
******************************************************************      21310000
*                                                                *      21320000
* CONVERT HEX DATA TO PRINTABLE FORM: 2 CHARACTERS PER BYTE. ON  *      21330000
* ENTRY, REG 12 CONTAINS THE ADDRESS OF THE LEFT END OF THE FIELD*      21340000
* TO BE CONVERTED, AND THE ENTRY POINT USED DETERMINES THE LENGTH*      21350000
* FORMATTED OUTPUT IS PLACED IN THE PRTABL FIELD.                *      21360000
*                                                                *      21370000
******************************************************************      21380000
HEXPRT   DS    0H                      HEX TO PRINTABLE ROUTINE         21390036
HEXPRT1  DS    0H                                                       21400045
         UNPK  PRTABL(3),0(2,R12)      UNPACK HEX                       21410045
         B     HEXCLTR                 CONTINUE                         21420000
HEXPRT2  DS    0H                                                       21430045
         UNPK  PRTABL(5),0(3,R12)      UNPACK HEX                       21440045
         B     HEXCLTR                 CONTINUE                         21450000
HEXPRT3  DS    0H                                                       21460045
         UNPK  PRTABL(7),0(4,R12)      UNPACK HEX                       21470045
         B     HEXCLTR                 CONTINUE                         21480000
HEXPRT4  DS    0H                                                       21490045
         UNPK  PRTABL(9),0(5,R12)      UNPACK HEX                       21500045
HEXCLTR  DS    0H                                                       21510045
         MVZ   PRTABL(8),XZROS         CLEAR FOR TRANSLATE              21520045
         TR    PRTABL(8),TRTBL         MAKE PRINTABLE                   21530000
         BR    R9                      EXIT                             21540000
******************************************************************      21550000
*                                                                *      21560000
* FORMATS THE HEX DATA CORRESPONDING TO THE FORMATTED INSTRUCTION*      21570000
* BEING OUTPUT. PRINTABLE HEX IS PLACED AT THE RIGHT OF THE LINE *      21580000
* ON THE SYSPRINT OUTPUT.                                        *      21590000
*                                                                *      21600000
******************************************************************      21610000
TXTFMT   DS    0H                      *** FORMAT TEXT FOR PRINT ***    21620036
         ST    R9,TX9                  SAVE RETURN ADDR                 21630000
         LA    R11,PRT                 @ PRINT LINE                     21640000
         CLI   TYPE,1                  ADCON                            21650000
         BE    TFOFST                  YES                              21660000
         CLI   TYPE,2                  CONSTANT                         21670000
         BE    TFOFST                  YES                              21680000
         CLI   TYPE,X'0D'              INSTRUCTION                      21690000
         BNE   TXTCLEAN                NO                               21700000
TFOFST   DS    0H                                                       21710045
         LA    R12,OFFSET              @ OFFSET TO INSTR                21720045
         BAL   R9,HEXPRT3              CONVERT TO PRINTABLE             21730000
         MVC   PRT+81(6),PRTABL        OFFSET TO PRINT              DSK 21740035
         LA    R12,LEN                 @ DATA LENGTH                    21750000
         BAL   R9,HEXPRT1              MAKE PRINTABLE                   21760000
         MVC   PRT+88(2),PRTABL        LENGTH TO PRINT              DSK 21770035
         LA    R12,TEXT                @ TEXT TO PRINT                  21780000
         BAL   R9,HEXPRT4              CONVERT 1ST 4 BYTES              21790000
         CLI   LEN,4                   IS IT 4 BYTES                    21800000
         BNL   TXT4                    YES, OR MORE                     21810000
         CLI   LEN,3                   IS IT 3 BYTES                    21820000
         BE    TXT3                    YES                              21830000
         CLI   LEN,2                   IS IT 2 BYTES                    21840000
         BE    TXT2                    YES                              21850000
         MVC   PRT+91(2),PRTABL        TEXT TO PRINT                DSK 21860035
         B     TXTCLEAN                FINISH                           21870000
TXT2     DS    0H                                                       21880045
         MVC   PRT+91(4),PRTABL        TEXT TO PRINT                DSK 21890045
         B     TXTCLEAN                FINISH                           21900000
TXT3     DS    0H                                                       21910045
         MVC   PRT+91(6),PRTABL        TEXT TO PRINT                DSK 21920045
         B     TXTCLEAN                FINISH                           21930000
TXT4     DS    0H                                                       21940045
         MVC   PRT+91(8),PRTABL        TEXT TO PRINT                DSK 21950045
         CLI   LEN,4                   IS IT 4 BYTES                    21960000
         BE    TXTCLEAN                YES, FINISH                      21970000
         LA    R12,TEXT+4              @ TEXT                           21980000
         BAL   R9,HEXPRT4              CONVERT                          21990000
         CLI   LEN,8                   8 BYTES OF TEXT OR MORE      DSK 22000035
         BNL   TXT8                    YES                          DSK 22010035
         CLI   LEN,7                   7 BYTES OF TEXT                  22020000
         BE    TXT7                    YES                              22030000
         CLI   LEN,6                   6 BYTES OF TEXT                  22040000
         BE    TXT6                    YES                              22050000
         MVC   PRT+99(2),PRTABL        TEXT TO PRINT                DSK 22060035
         B     TXTCLEAN                FINISH                           22070000
TXT6     DS    0H                                                       22080045
         MVC   PRT+99(4),PRTABL        TEXT TO PRINT                DSK 22090045
         B     TXTCLEAN                FINISH                           22100000
TXT7     DS    0H                                                       22110045
         MVC   PRT+99(6),PRTABL        TEXT TO PRINT                DSK 22120045
         B     TXTCLEAN                FINISH                           22130000
TXT8     DS    0H                                                       22140045
         MVC   PRT+99(8),PRTABL        TEXT TO PRINT                DSK 22150045
         CLI   LEN,8                   8 BYTES OF TEXT OR LESS      DSK 22160035
         BNH   TXTCLEAN                YES                          DSK 22170035
         LA    R12,TEXT+8              @ TEXT                       DSK 22180035
         BAL   R9,HEXPRT4              CONVERT                      DSK 22190035
         MVC   PRT+107(2),PRTABL       TEXT TO PRINT                DSK 22200035
         CLI   LEN,9                   9 BYTES OF TEXT OR LESS      DSK 22210035
         BNH   TXTCLEAN                YES                          DSK 22220035
         MVC   PRT+109(2),PRTABL+2     TEXT TO PRINT                DSK 22230035
         CLI   LEN,10                  10 BYTES OF TEXT OR LESS     DSK 22240035
         BNH   TXTCLEAN                YES                          DSK 22250035
         MVC   PRT+111(2),PRTABL+4     TEXT TO PRINT                DSK 22260035
         CLI   LEN,11                  11 BYTES OF TEXT OR LESS     DSK 22270035
         BNH   TXTCLEAN                YES                          DSK 22280035
         MVC   PRT+113(2),PRTABL+6     TEXT TO PRINT                DSK 22290035
         CLI   LEN,12                  12 BYTES OF TEXT OR LESS     DSK 22300035
         BNH   TXTCLEAN                YES                          DSK 22310035
         LA    R12,TEXT+12             @ TEXT                       DSK 22320035
         BAL   R9,HEXPRT4              CONVERT                      DSK 22330035
         MVC   PRT+115(2),PRTABL       TEXT TO PRINT                DSK 22340035
         CLI   LEN,13                  13 BYTES OF TEXT OR LESS     DSK 22350035
         BNH   TXTCLEAN                YES                          DSK 22360035
         MVC   PRT+117(2),PRTABL+2     TEXT TO PRINT                DSK 22370035
         CLI   LEN,14                  14 BYTES OF TEXT OR LESS     DSK 22380035
         BNH   TXTCLEAN                YES                          DSK 22390035
         MVC   PRT+119(2),PRTABL+4     TEXT TO PRINT                DSK 22400035
TXTCLEAN DS    0H                                                       22410045
         XC    OFFSET,OFFSET           CLEAR                        DSK 22420045
         L     R9,TX9                  GET RETURN ADDR                  22430000
         BR    R9                      EXIT                             22440000
******************************************************************      22450000
*                                                                *      22460000
* ENTERED WHENEVER THE CURRENT TEXT OFFSET IS PAST THE NEXCHG    *      22470000
* FIELD VALUE. THIS ROUTINE CREATES DROP CARDS FOR EXHAUSTED BASE*      22480000
* REGISTERS, AND USING STATEMENTS FOR NEW BASE REGISTERS. THE    *      22490000
* BASES TABLE IS SCANNED, AND ANY ENTRY WHICH IS NO LONGER IN USE*      22500000
* IS ZEROED OUT, AND A DROP RECORD IS CREATED. NEXT, THE USING   *      22510000
* TABLE IS SCANNED. WHEN AN ENTRY IS FOUND WHICH IS VALID AT THE *      22520000
* CURRENT OFFSET, THE BASE TABLE IS CHECKED. IF THE ENTRY IS NOT *      22530000
* IN USE, A USING STATEMENT IN CREATED, AND THE USING TABLE ENTRY*      22540000
* IS MOVED TO THE BASES TABLE. THE NEXCHG FIELD IS CHANGED TO    *      22550000
* CONTAIN THE OFFSET AT WHICH THE NEXT SCAN MUST BE MADE. AN IND-*      22560000
* ICATOR CALLED MORUSG IS SET TO SHOW WHEN ANY BASE REGISTERS ARE*      22570000
* CURRENTLY IN USE. WHEN NO MORE REGISTERS ARE AVAILABLE, THE    *      22580000
* NEXCHG FIELD IS SET TO HEX FF'S.                               *      22590000
*                                                                *      22600000
******************************************************************      22610000
NEXUSG   DS    0H                      *** GET NEXT BASE REG SET ***    22620036
         MVC   NEXCHG,HIVAL            RESET NEXT CHANGE ADDR           22630000
         MVI   MORUSG,0                CLEAR BASE REG AVAIL INDIC       22640000
         ST    R9,USG9                 SAVE RETURN ADDR                 22650000
         XC    BASES(L'USING),BASES    CLEAR R0 ELEMENT                 22660000
         MVC   BASES+16*L'USING(4),HIVAL SET TABLE STOPPER              22670000
         USING USINGD,R2                                                22680000
         LA    R2,BASES+L'USING        @ R1'S ELEMENT                   22690000
DRPCKND  DS    0H                                                       22700045
         CLI   0(R2),X'FF'             END OF TABLE                     22710045
         BE    USGUSG                  YES                              22720000
         CLC   USEND,XZROS             ENTRY USED                       22730000
         BE    DRPSTEP                 NO                               22740000
         CLC   TXTOFST+1(3),USEND      PAST END OF THIS ONE             22750035
         BL    DRPSTEP                 NO                               22760000
         MVC   MNEMONIC(4),=C'DROP'    OPERATION IS DROP                22770000
         MVI   OPNDS,C'R'              DELIMITER FOR REGS               22780000
         SR    R12,R12                 CLEAR WORK                       22790000
         IC    R12,USREG               GET REG                          22800000
         CVD   R12,DBLWD               CONVERT TO PACKED                22810000
         UNPK  DBLWD(2),DBLWD+6(2)     UNPACK                           22820000
         OI    DBLWD+1,C'0'            CLEAR SIGN                       22830000
         CH    R12,=H'10'              REG < 10                         22840052
         BL    DPR1                    YES                              22850000
         MVC   OPNDS+1(2),DBLWD        MOVE REG NBR                     22860000
         B     WRTDROP                 GO WRITE DROP                    22870000
DPR1     DS    0H                                                       22880045
         MVC   OPNDS+1(1),DBLWD+1      MOVE 1-DIGIT REG                 22890045
WRTDROP  DS    0H                                                       22900045
         BAL   R9,WRTOUT               WRITE DROP RECORD                22910045
         BAL   R9,PRINT                PRINT DROP RECORD                22920000
         XC    USING,USING             CLEAR THE ENTRY                  22930000
DRPSTEP  DS    0H                                                       22940045
         LA    R2,L'USING(,R2)         TO NEXT BASE ELEMENT             22950045
         B     DRPCKND                 LOOP                             22960000
USGUSG   DS    0H                                                       22970045
         L     R2,USGSTRT              GET FIRST USING TBL ADDR         22980045
ENDUS    DS    0H                                                       22990045
         CLI   0(R2),X'FF'             END OF TABLE                     23000045
         BE    XITUS                   YES                              23010000
         CLC   TXTOFST+1(3),USEND      PAST END OF THIS ONE             23020035
         BNL   ECSTEP                  YES                              23030000
         OI    MORUSG,1                SHOW MORE BASES AVAIL            23040000
USBGCK   DS    0H                                                       23050045
         CLC   TXTOFST+1(3),USBGN      CURR LOC BEFORE THIS             23060045
         BNL   CKNEWLO                 NO                               23070000
         CLC   USBGN,NEXCHG            BEGINS BEFORE NEXT CHANGE        23080000
         BNL   ECSTEP                  NO                               23090000
         MVC   NEXCHG,USBGN            YES, SET LOWER CHANGE OFFSET     23100000
         B     ECSTEP                  CONTINUE                         23110000
CKNEWLO  DS    0H                                                       23120045
         CLC   USEND,NEXCHG            THIS ENTRY ENDS EARLIER          23130045
         BNL   ECMVC                   NO                               23140000
         MVC   NEXCHG,USEND            YES, SET NEW END                 23150000
ECMVC    DS    0H                                                       23160045
         SR    R1,R1                   CLEAR WORK                       23170045
         IC    R1,USREG                PICK UP REG                      23180000
         MH    R1,USGLEN               TIMES ENTRY LENGTH               23190000
         LA    R1,BASES(R1)            @ BASE TABLE ENTRY               23200000
         OI    MORUSG,X'80'            SHOW BASE IN USE                 23210000
         CLC   USING,0(R1)             OLD AND NEW IDENTICAL            23220000
         BE    ECSTEP                  YES                              23230000
MAKUSG   DS    0H                                                       23240045
         MVC   0(L'USING,R1),USING     NEW USING TO TABLE               23250045
         MVC   MNEMONIC(5),=C'USING'   OPERATION IS USING               23260000
         CLI   USTYPE,C'D'             IS IT A DSECT                    23270000
         BNE   CKUTPS                  NO                               23280000
         ICM   R12,7,USVALU            YES, GET DSECT HEADER ADDR       23290000
         L     R11,DTBSTRT             @ 1ST DSECT HEADER ENTRY         23300000
         USING DTBD,R11                                                 23310036
DSCTEND  DS    0H                                                       23320045
         C     R11,DTBCURR             END OF TABLE                     23330045
         BH    MVDSNAME                YES                              23340000
         CLM   R12,7,DTBFLD@           THIS THE HEADER ENTRY            23350036
         BNE   DSCTSTEP                NO                               23360000
         LR    R12,R11                 YES, COPY IT'S ADDRESS           23370000
         B     MVDSNAME                CONTINUE                         23380000
DSCTSTEP DS    0H                                                       23390045
         LA    R11,L'DTB(,R11)         TO NEXT HEADER ENTRY             23400045
         B     DSCTEND                 LOOP THRU TABLE                  23410000
         DROP  R11                                                      23420036
         USING DTBD,R12                                                 23430036
MVDSNAME DS    0H                                                       23440045
         MVC   OPNDS(8),DTBNAM         DSECT NAME TO OPERANDS           23450045
         DROP  R12                                                      23460036
         LA    R12,OPNDS+7             TO END OF NAME                   23470000
USFRHED  DS    0H                                                       23480045
         CLI   0(R12),C' '             FOUND RHE                        23490045
         BNE   USFMADD                 YES                              23500000
         BCT   R12,USFRHED             BACK UP 1 AND LOOP               23510000
USFMADD  DS    0H                                                       23520045
         LA    R12,1(,R12)             TO NEXT BYTE                     23530045
USFMCMA  DS    0H                                                       23540045
         MVC   0(2,R12),=C',R'         DELIMITERS                       23550045
         SR    R11,R11                 CLEAR WORK                       23560000
         IC    R11,USREG               GET REGISTER NBR                 23570000
         CVD   R11,DBLWD               CONVERT TO PACKED                23580000
         UNPK  DBLWD(2),DBLWD+6(2)     UNPACK REG NBR                   23590000
         OI    DBLWD+1,C'0'            CLEAR SIGN                       23600000
         CH    R11,=H'10'              REG < 10                         23610052
         BL    USFMR1                  YES                              23620000
         MVC   2(2,R12),DBLWD          MOVE 2-DIGIT REG NBR             23630000
         B     USINGOUT                GO WRITE USING                   23640000
USFMR1   DS    0H                                                       23650045
         MVC   2(1,R12),DBLWD+1        MOVE 1-DIGIT REG NBR             23660045
USINGOUT DS    0H                                                       23670045
         BAL   R9,WRTOUT               WRITE USING STMT                 23680045
         BAL   R9,PRINT                PRINT USING STMT                 23690000
         B     ECSTEP                  CONTINUE                         23700000
CKUTPS   DS    0H                                                       23710045
         CLC   USVALU,TXTOFST+1        USING AT CURR LOC                23720045
         BNE   USFMLBL                 NO                               23730000
         MVI   OPNDS,C'*'              SET CURRENT LOC SYMBOL IN OPERAN 23740000
         LA    R12,OPNDS+1             GET NEXT POS ADDR                23750000
         B     USFMCMA                 GO FORMAT REG                    23760000
USFMLBL  DS    0H                                                       23770045
         MVI   OPNDS,C'A'              SET 1ST CHAR OF LABEL NAME       23780045
         LA    R12,USVALU              GET OFFSET                       23790000
         BAL   R9,HEXPRT3              CONVERT TO PRINTABLE             23800000
         MVC   OPNDS+1(6),PRTABL       PRINTABLE HEX TO LABEL           23810000
         LA    R12,OPNDS+7             TO NEXT LOC                      23820000
         B     USFMCMA                 FORMAT REG                       23830000
ECSTEP   DS    0H                                                       23840045
         LA    R2,L'USING(,R2)         TO NEXT USING ENTRY              23850045
         B     ENDUS                   CONTINUE SCAN                    23860000
XITUS    DS    0H                                                       23870045
         L     R9,USG9                 GET RETURN ADDR                  23880045
         BR    R9                      EXIT                             23890000
******************************************************************      23900054
* Trace the net label entry                                      *      23910054
******************************************************************      23920054
         USING LABELD,R6                                                23930054
LBLTRC   DS    0H                                                       23940054
         TM    PRMOPT,DBGLABEL         Label debug                      23950054
         BNOR  R9                      No                               23960054
*        C     R6,CURRLBL              End of EQU table?                23961054
*        BNLR  R9                      Yes                              23962054
         ST    R9,LBLTRCR9             Save return                      23970054
         MVC   SAVPRT,PRT                                               23980054
         MVC   PRT,BLANX                                                23990054
         MVI   PRT,C'>'                                                 23991054
         MVC   PRT+01(8),LBLNAME                                        24000054
         MVC   PRT+10(3),=C'TY='                                        24010054
         MVC   PRT+13(1),LBLTYP        LABEL TYPE                       24020054
         MVC   PRT+15(2),=C'L='                                         24030054
         UNPK  PRT+17(3),LBLLEN(2)     LENGTH                           24040054
         TR    PRT+17(2),TRTBL-240                                      24050054
         MVC   PRT+19(3),=C' A='       ADDRESS                          24060054
         UNPK  PRT+22(7),LBLADR(4)                                      24070054
         TR    PRT+22(6),TRTBL-240                                      24080054
         MVI   PRT+28,C' '                                              24090054
         MVC   PRT+29(4),=C'from'      Where called from                24100054
         LR    R0,R9                                                    24110054
         SR    R0,R3                                                    24120054
         STH   R0,DBLWD                                                 24130054
         UNPK  PRT+34(5),DBLWD(3)                                       24140054
         TR    PRT+34(4),TRTBL-240                                      24150054
         MVI   PRT+38,C'<'                                              24160054
         BAL   R9,PRINT                                                 24170054
         MVC   PRT,SAVPRT                                               24180054
         L     R9,LBLTRCR9             Get return                       24190054
         BR    R9                      EXIT                             24200054
         DROP  R6                                                       24210054
******************************************************************      24220000
*                                                                *      24230000
* END OF PHASE 2 - RETURN TO PHASE 0                             *      24240000
*                                                                *      24250000
******************************************************************      24260000
EOJ      DS    0H                      END OF JOB                       24270036
         BAL   R9,FORCONST             YES, FORCE IT OUT                24280000
         OI    EQUOPFLG,X'80'          Set EQU operand type flag    DSK 24290036
EOJ10    DS    0H                                                   DSK 24300036
         C     R6,CURRLBL              End of EQU table?            DSK 24310036
         BNL   EOJ30                   Yes, last EQU completed      DSK 24320036
         USING LABELD,R6                                            DSK 24330025
         CLI   LBLNAME,C' '            Label name present?          DSK 24340023
         BNH   EOJ20                   No, last EQU completed       DSK 24350036
         CLI   LBLTYP,LBLTYPL          Is this a label?             DSK 24360048
         BNE   EOJ20                   No, last EQU completed       DSK 24370036
         BAL   R9,EQUSTMT              Build EQU statememt          DSK 24380023
         NI    LBLTYP,X'BF'            We handled this label        DSK 24390036
EOJ20    DS    0H                                                   DSK 24400036
         LA    R6,L'LABEL(,R6)         Next entry                   DSK 24410036
         B     EOJ10                   Run rest of table            DSK 24420036
         DROP  R6                                                   DSK 24430023
EOJ30    DS    0H                                                   DSK 24440036
         L     R13,4(,R13)             GET POINTER TO CALLER'S SAVE ARE 24450036
         LM    R14,R12,12(R13)         RESTORE CALLER'S REGS            24460000
         SR    R15,R15                 CLEAR RETURN CODE                24470000
         BR    R14                     RETURN TO CALLER                 24480000
******************************************************************      24490036
*                                                                *      24500036
*                 *** DATA AND WORK AREAS ***                    *      24510036
*                                                                *      24520036
******************************************************************      24530036
         LTORG ,                                                        24540052
SVCTBLAD DC    A(SVCOP)                @ SVC TABLE                      24550000
DBLOPAD  DC    A(DBLOP)                @ TWO-BYTE OP-CODE TBL           24560000
OWSTRT   DC    A(OPNDWK)               @ OPERAND WORK AREA              24570000
OPND9    DC    A(OPNDRTN)              RETURN ADDR FOR OPERAND ROUTINES 24580000
USG12    DC    2F'0'                   REG SAVE AREA                    24590036
USG9     DC    F'0'                    RETURN SAVE                      24600036
EQU9     DC    F'0'                    RETURN ADDR FOR EQUSTMT          24610036
FC6      DC    F'0'                    SAVE AREA FOR R6                 24620036
FC9      DC    F'0'                    FORCONST RETURN ADDR             24630036
TX9      DC    F'0'                    RETURN ADDR FOR TXTFMT           24640036
BD9      DC    F'0'                    RETURN FOR BDADR                 24650036
BDX9     DC    F'0'                    RETURN FOR BDXADR                24660036
BDL9     DC    F'0'                    RETURN FOR BDLADR                24670036
LBLTRCR9 DC    F'0'                    RETURN FOR BDLADR                24680054
SLSAV    DC    4F'0'                   SAVE FOR SCHLBL                  24690036
XZROS    DC    8X'00'                  CONSTANT ZEROS                   24700052
HIVAL    DC    4X'FF'                  CONSTANT X F'S                   24710052
SGOPLEN  DC    AL2(L'SGLOP)            SINGLE BYTE OP COD TBL LEN       24720036
ILENG    DC    H'0'                    INSTRUCTION LENGTH  FIX***       24730000
CONPROG  DC    X'00'                   CONSTANT IN PROGRESS INDIC       24740000
*                                                                       24750036
CONPSLBL DS    0CL13                   PSEUDO LABEL ENTRY FOR CONSTANTS 24760000
CONADR   DC    XL3'0'                  RELATIVE ADDR IN TEXT            24770045
CONTYPE  DC    CL1' '                  TYPE                             24780045
CONNAME  DC    CL8' '                  CONSTANT NAME                    24790036
CONLLEN  DC    XL1'0'                  LABEL LENGTH                     24800036
*                                                                       24810045
EQUOPFLG DC    X'0'                    EQU * of csect+X'offset'         24820045
         DC    0H'0'                                                    24830036
CONDATA  DC    XL50'0'                 CONSTANT DATA                    24840036
CONSYM   DC    CL8' '                  CONSTANT SYMBOL                  24850036
CONLEN   DC    H'0'                    CONSTANT LENGTH                  24860036
CONOFST  DC    F'0'                    RELATIVE OFFSET TO CONSTANT      24870036
CONLOC   DC    F'0'                    @ CURRENT BYTE IN CONSTANT       24880036
TXTOFST  DC    F'0'                    OFFSET TO TEXT BYTE              24890036
CCTYPE   DC    X'00'                   CC SET TYPE OF INSTR SETTING     24900035
OPNDWK   DC    CL13' '                 OPERAND BUILD AREA               24910036
OFFSET   DC    XL3'0'                  OFFSET FROM PGM START            24920036
INSTYP   DC    CL1'0'                  INSTRUCTION TYPE                 24930036
TYPE     DC    XL1'0'                  TYPE CODE                        24940036
*                                       0=CSECT, 1=ADCON, 2=CONST       24950000
*                                       E=USING, D=INSTRUCTION          24960000
*                                       C=COMMENT, 9=ENTRY              24970000
*                                       A=EQU                           24980000
LEN      DC    XL1'0'                  TEXT LENGTH                      24990036
TEXT     DC    XL50'0'                 TEXT                             25000036
BLANX    DC    CL121' '                CONSTANT BLANKS                  25010000
NEXCHG   DC    XL3'00'                 OFFSET TO NEXT BASE REG CHG      25020000
USGLEN   DC    AL2(L'USING) LENGTH OF USING TBL ENTRIES                 25030036
MORUSG   DC    X'00'                   0=NO MORE BASES, 80=MORE BASES   25040036
CONTRC   DC    C'    '                                              DSK 25050035
TRTBL    DC    C'0123456789ABCDEF'     TRANSLATE TBL                    25060000
PRTABL   DC    CL9' '                  PRINTABLE HEX WORK               25070036
SAVPRT   DC    CL121' '                                                 25080054
BASES    DC    XL256'00'               BASE REG TABLE                   25090000
*                                                                       25100000
* INSTRUCTION DISASSEMBLY TABLES. THESE TABLES DEFINE VALID             25110000
* INSTRUCTION OP-CODES, AND GIVE MNEMONICS, FORMAT-TYPES,               25120000
* AND AN INDICATOR TO SHOW CONDITION SETTING INSTRUCTIONS,              25130000
* PRIVILEGED INSTRUCTIONS, AND FLOATING POINT INSTRUCTIONS.             25140000
*                                                                       25150000
*                                                                       25160000
INSTENT  DS    0CL10                   CURRENT INSTRUCTION ENTRY        25170000
INAME    DC    CL5' '                  INSTR NAME (MNEMONIC)            25180036
ITYPE    DC    XL1'0'                  INSTRUCTION TYPE                 25190036
RR       EQU   0                       RR FORMAT                        25200000
RX       EQU   4                       RX FORMAT                        25210000
S        EQU   8                       S FORMAT                         25220000
SI       EQU   12                      SI FORMAT                        25230000
RS       EQU   16                      RS FORMAT                        25240000
SS1      EQU   20                      SS FORMAT, SINGLE LENGTH         25250000
SS2      EQU   24                      SS FORMAT, 2 LENGTHS             25260000
TWO      EQU   28                      TWO BYTE OP-CODE                 25270000
CONDBR   EQU   32                      CONDITIONAL BRANCH               25280000
SVC      EQU   36                      SUPERVISOR CALL                  25290000
ICLASS   DC    XL1'0'                  INSTRUCTION CLASS                25300036
PRIV     EQU   2                       PRIVILEGED INSTRUCTION           25310000
FLTPT    EQU   4                       FLOATING POINT INSTRUCTION       25320000
FLSHT    EQU   5                       SHORT PREC FLT PT INSTR          25330000
IEDT     DC    XL1'0'                  INSTRUCTION EDITS                25340036
EPR      EQU   X'40'                   EVEN-ODD REGISTER PAIR           25350000
E2       EQU   X'20'                   2ND OPND ON HALFWORD BOUND       25360000
E4       EQU   X'10'                   2ND OPND ON FULLWORD BOUND       25370000
E8       EQU   X'08'                   2ND OPND ON DBL WORD BOUND       25380000
S1       EQU   X'02'                   1ST OPND MUST HAVE BASE/INDEX    25390000
S2       EQU   X'01'                   2ND OPND MUST HAVE BASE          25400000
ICCSET   DC    XL1'0'                  TYPE CONDITION CODE SET          25410036
ARITH    EQU   X'80'                   ARITHMETIC TYPE                  25420000
CPR      EQU   X'40'                   COMPARE TYPE                     25430000
ZRO8     EQU   X'20'                   BC 8 MAY BE BZ                   25440000
INLNG    DC    XL1'0'                  INSTRUCTION LENGTH               25450036
*                                                                       25460000
*                                                                       25470000
*                                                                       25480000
SGLOP    DS    0CL10                   SINGLE BYTE OP-CODE TABLE        25490000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'02' NOT INSTR      25500000
         DC    CL5' ',AL1(TWO),AL1(0),AL1(0),AL1(0),X'02' 01            25510005
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'02' NOT INSTR      25520000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'02' NOT INSTR      25530000
         DC    CL5'SPM',AL1(RR),AL1(0),AL1(0),AL1(0),X'02' 04           25540000
         DC    CL5'BALR',AL1(RR),AL1(0),AL1(0),AL1(0),X'02' 05          25550000
         DC    CL5'BCTR',AL1(RR),AL1(0),AL1(0),AL1(0),X'02' 06          25560000
         DC    CL5'BCR',AL1(CONDBR),AL1(0),AL1(0),AL1(0),X'02' 07       25570000
         DC    CL5'SSK',AL1(RR),AL1(PRIV),AL1(0),AL1(0),X'02' 08        25580000
         DC    CL5'ISK',AL1(RR),AL1(PRIV),AL1(0),AL1(0),X'02' 09        25590000
         DC    CL5'SVC',AL1(SVC),AL1(0),AL1(0),AL1(0),X'02' 0A          25600000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'02' NOT INSTR      25610000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'02' NOT INSTR      25620000
         DC    CL5'BASR',AL1(RR),AL1(0),AL1(0),AL1(0),X'02' 0D          25630008
         DC    CL5'MVCL',AL1(RR),AL1(0),AL1(EPR),AL1(0),X'02' 0E        25640000
         DC    CL5'CLCL',AL1(RR),AL1(0),AL1(EPR),AL1(0),X'02' 0F        25650000
         DC    CL5'LPR',AL1(RR),AL1(0),AL1(0),AL1(ARITH),X'02' 10       25660000
         DC    CL5'LNR',AL1(RR),AL1(0),AL1(0),AL1(ARITH),X'02' 11       25670000
         DC    CL5'LTR',AL1(RR),AL1(0),AL1(0),AL1(ARITH),X'02' 12       25680000
         DC    CL5'LCR',AL1(RR),AL1(0),AL1(0),AL1(ARITH),X'02' 13       25690000
         DC    CL5'NR',AL1(RR),AL1(0),AL1(0),AL1(ZRO8),X'02' 14         25700000
         DC    CL5'CLR',AL1(RR),AL1(0),AL1(0),AL1(CPR),X'02' 15         25710000
         DC    CL5'OR',AL1(RR),AL1(0),AL1(0),AL1(ZRO8),X'02' 16         25720000
         DC    CL5'XR',AL1(RR),AL1(0),AL1(0),AL1(ZRO8),X'02' 17         25730000
         DC    CL5'LR',AL1(RR),AL1(0),AL1(0),AL1(0),X'02' 18            25740000
         DC    CL5'CR',AL1(RR),AL1(0),AL1(0),AL1(CPR),X'02' 19          25750000
         DC    CL5'AR',AL1(RR),AL1(0),AL1(0),AL1(ARITH),X'02' 1A        25760000
         DC    CL5'SR',AL1(RR),AL1(0),AL1(0),AL1(ARITH),X'02' 1B        25770000
         DC    CL5'MR',AL1(RR),AL1(0),AL1(EPR),AL1(0),X'02' 1C          25780000
         DC    CL5'DR',AL1(RR),AL1(0),AL1(EPR),AL1(0),X'02' 1D          25790000
         DC    CL5'ALR',AL1(RR),AL1(0),AL1(0),AL1(0),X'02' 1E           25800000
         DC    CL5'SLR',AL1(RR),AL1(0),AL1(0),AL1(0),X'02' 1F           25810000
         DC    CL5'LPDR',AL1(RR),AL1(FLTPT),AL1(0),AL1(ARITH),X'02' 20  25820000
         DC    CL5'LNDR',AL1(RR),AL1(FLTPT),AL1(0),AL1(ARITH),X'02' 21  25830000
         DC    CL5'LTDR',AL1(RR),AL1(FLTPT),AL1(0),AL1(ARITH),X'02' 22  25840000
         DC    CL5'LCDR',AL1(RR),AL1(FLTPT),AL1(0),AL1(ARITH),X'02' 23  25850000
         DC    CL5'HDR',AL1(RR),AL1(FLTPT),AL1(0),AL1(0),X'02' 24       25860000
         DC    CL5'LRDR',AL1(RR),AL1(FLTPT),AL1(0),AL1(0),X'02' 25      25870000
         DC    CL5'MXR',AL1(RR),AL1(FLTPT),AL1(0),AL1(0),X'02' 26       25880000
         DC    CL5'MXDR',AL1(RR),AL1(FLTPT),AL1(0),AL1(0),X'02' 27      25890000
         DC    CL5'LDR',AL1(RR),AL1(FLTPT),AL1(0),AL1(0),X'02' 28       25900000
         DC    CL5'CDR',AL1(RR),AL1(FLTPT),AL1(0),AL1(CPR),X'02' 29     25910000
         DC    CL5'ADR',AL1(RR),AL1(FLTPT),AL1(0),AL1(ARITH),X'02' 2A   25920000
         DC    CL5'SDR',AL1(RR),AL1(FLTPT),AL1(0),AL1(ARITH),X'02' 2B   25930000
         DC    CL5'MDR',AL1(RR),AL1(FLTPT),AL1(0),AL1(0),X'02' 2C       25940000
         DC    CL5'DDR',AL1(RR),AL1(FLTPT),AL1(0),AL1(0),X'02' 2D       25950000
         DC    CL5'AWR',AL1(RR),AL1(FLTPT),AL1(0),AL1(ARITH),X'02' 2E   25960000
         DC    CL5'SWR',AL1(RR),AL1(FLTPT),AL1(0),AL1(ARITH),X'02' 2F   25970000
         DC    CL5'LPER',AL1(RR),AL1(FLTPT),AL1(0),AL1(ARITH),X'02' 30  25980000
         DC    CL5'LNER',AL1(RR),AL1(FLTPT),AL1(0),AL1(ARITH),X'02' 31  25990000
         DC    CL5'LTER',AL1(RR),AL1(FLTPT),AL1(0),AL1(ARITH),X'02' 32  26000000
         DC    CL5'LCER',AL1(RR),AL1(FLTPT),AL1(0),AL1(ARITH),X'02' 33  26010000
         DC    CL5'HER',AL1(RR),AL1(FLTPT),AL1(0),AL1(0),X'02' 34       26020000
         DC    CL5'LRER',AL1(RR),AL1(FLTPT),AL1(0),AL1(0),X'02' 35      26030000
         DC    CL5'AXR',AL1(RR),AL1(FLTPT),AL1(0),AL1(ARITH),X'02' 36   26040000
         DC    CL5'SXR',AL1(RR),AL1(FLTPT),AL1(0),AL1(ARITH),X'02' 37   26050000
         DC    CL5'LER',AL1(RR),AL1(FLTPT),AL1(0),AL1(0),X'02' 38       26060000
         DC    CL5'CER',AL1(RR),AL1(FLTPT),AL1(0),AL1(CPR),X'02' 39     26070000
         DC    CL5'AER',AL1(RR),AL1(FLTPT),AL1(0),AL1(ARITH),X'02' 3A   26080000
         DC    CL5'SER',AL1(RR),AL1(FLTPT),AL1(0),AL1(ARITH),X'02' 3B   26090000
         DC    CL5'MER',AL1(RR),AL1(FLTPT),AL1(0),AL1(0),X'02' 3C       26100000
         DC    CL5'DER',AL1(RR),AL1(FLTPT),AL1(0),AL1(0),X'02' 3D       26110000
         DC    CL5'AUR',AL1(RR),AL1(FLTPT),AL1(0),AL1(ARITH),X'02' 3E   26120000
         DC    CL5'SUR',AL1(RR),AL1(FLTPT),AL1(0),AL1(ARITH),X'02' 3F   26130000
         DC    CL5'STH',AL1(RX),AL1(0),AL1(E2+S2),AL1(0),X'04' 40       26140000
         DC    CL5'LA',AL1(RX),AL1(0),AL1(0),AL1(0),X'04' 41            26150000
         DC    CL5'STC',AL1(RX),AL1(0),AL1(S2),AL1(0),X'04' 42          26160000
         DC    CL5'IC',AL1(RX),AL1(0),AL1(0),AL1(0),X'04' 43            26170000
         DC    CL5'EX',AL1(RX),AL1(0),AL1(E2+S2),AL1(0),X'04' 44        26180000
         DC    CL5'BAL',AL1(RX),AL1(0),AL1(E2),AL1(0),X'04' 45          26190000
         DC    CL5'BCT',AL1(RX),AL1(0),AL1(E2+S2),AL1(0),X'04' 46       26200000
         DC    CL5'BC',AL1(CONDBR),AL1(0),AL1(E2),AL1(0),X'04' 47       26210000
         DC    CL5'LH',AL1(RX),AL1(0),AL1(E2),AL1(0),X'04' 48           26220000
         DC    CL5'CH',AL1(RX),AL1(0),AL1(E2),AL1(CPR),X'04' 49         26230000
         DC    CL5'AH',AL1(RX),AL1(0),AL1(E2),AL1(ARITH),X'04' 4A       26240000
         DC    CL5'SH',AL1(RX),AL1(0),AL1(E2),AL1(ARITH),X'04' 4B       26250000
         DC    CL5'MH',AL1(RX),AL1(0),AL1(E2),AL1(0),X'04' 4C           26260000
         DC    CL5'BAS',AL1(RX),AL1(0),AL1(E2),AL1(0),X'04' 4D          26270008
         DC    CL5'CVD',AL1(RX),AL1(0),AL1(E8+S2),AL1(0),X'04' 4E       26280000
         DC    CL5'CVB',AL1(RX),AL1(0),AL1(E8),AL1(0),X'04' 4F          26290000
         DC    CL5'ST',AL1(RX),AL1(0),AL1(E4+S2),AL1(0),X'04' 50        26300000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      26310000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      26320000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      26330000
         DC    CL5'N',AL1(RX),AL1(0),AL1(E4),AL1(ZRO8),X'04' 54         26340000
         DC    CL5'CL',AL1(RX),AL1(0),AL1(E4),AL1(CPR),X'04' 55         26350000
         DC    CL5'O',AL1(RX),AL1(0),AL1(E4),AL1(ZRO8),X'04' 56         26360000
         DC    CL5'X',AL1(RX),AL1(0),AL1(E4),AL1(ZRO8),X'04' 57         26370000
         DC    CL5'L',AL1(RX),AL1(0),AL1(E4),AL1(0),X'04' 58            26380000
         DC    CL5'C',AL1(RX),AL1(0),AL1(E4),AL1(CPR),X'04' 59          26390000
         DC    CL5'A',AL1(RX),AL1(0),AL1(E4),AL1(ARITH),X'04' 5A        26400000
         DC    CL5'S',AL1(RX),AL1(0),AL1(E4),AL1(ARITH),X'04' 5B        26410000
         DC    CL5'M',AL1(RX),AL1(0),AL1(E4+EPR),AL1(0),X'04' 5C        26420000
         DC    CL5'D',AL1(RX),AL1(0),AL1(E4+EPR),AL1(0),X'04' 5D        26430000
         DC    CL5'AL',AL1(RX),AL1(0),AL1(E4),AL1(0),X'04' 5E           26440000
         DC    CL5'SL',AL1(RX),AL1(0),AL1(E4),AL1(0),X'04' 5F           26450000
         DC    CL5'STD',AL1(RX),AL1(FLTPT),AL1(0),AL1(0),X'04' 60       26460000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      26470000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      26480000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      26490000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      26500000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      26510000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      26520000
         DC    CL5'MXD',AL1(RX),AL1(FLTPT),AL1(0),AL1(0),X'04' 67       26530000
         DC    CL5'LD',AL1(RX),AL1(FLTPT),AL1(0),AL1(0),X'04' 68        26540000
         DC    CL5'CD',AL1(RX),AL1(FLTPT),AL1(0),AL1(CPR),X'04' 69      26550000
         DC    CL5'AD',AL1(RX),AL1(FLTPT),AL1(0),AL1(ARITH),X'04' 6A    26560000
         DC    CL5'SD',AL1(RX),AL1(FLTPT),AL1(0),AL1(ARITH),X'04' 6B    26570000
         DC    CL5'MD',AL1(RX),AL1(FLTPT),AL1(0),AL1(0),X'04' 6C        26580000
         DC    CL5'DD',AL1(RX),AL1(FLTPT),AL1(0),AL1(0),X'04' 6D        26590000
         DC    CL5'AW',AL1(RX),AL1(FLTPT),AL1(0),AL1(ARITH),X'04' 6E    26600000
         DC    CL5'SW',AL1(RX),AL1(FLTPT),AL1(0),AL1(ARITH),X'04' 6F    26610000
         DC    CL5'STE',AL1(RX),AL1(FLSHT),AL1(0),AL1(0),X'04' 70       26620000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      26630000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      26640000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      26650000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      26660000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      26670000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      26680000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      26690000
         DC    CL5'LE',AL1(RX),AL1(FLSHT),AL1(0),AL1(0),X'04' 78        26700000
         DC    CL5'CE',AL1(RX),AL1(FLSHT),AL1(0),AL1(CPR),X'04' 79      26710000
         DC    CL5'AE',AL1(RX),AL1(FLSHT),AL1(0),AL1(ARITH),X'04' 7A    26720000
         DC    CL5'SE',AL1(RX),AL1(FLSHT),AL1(0),AL1(ARITH),X'04' 7B    26730000
         DC    CL5'ME',AL1(RX),AL1(FLSHT),AL1(0),AL1(0),X'04' 7C        26740000
         DC    CL5'DE',AL1(RX),AL1(FLSHT),AL1(0),AL1(0),X'04' 7D        26750000
         DC    CL5'AU',AL1(RX),AL1(FLSHT),AL1(0),AL1(ARITH),X'04' 7E    26760000
         DC    CL5'SU',AL1(RX),AL1(FLSHT),AL1(0),AL1(ARITH),X'04' 7F    26770000
         DC    CL5'SSM',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04' 80         26780000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      26790000
         DC    CL5'LPSW',AL1(S),AL1(PRIV),AL1(E8),AL1(0),X'04' 82       26800000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      26810000
         DC    CL5'WRD',AL1(SI),AL1(PRIV),AL1(0),AL1(0),X'04' 84        26820000
         DC    CL5'RDD',AL1(SI),AL1(PRIV),AL1(0),AL1(0),X'04' 85        26830000
         DC    CL5'BXH',AL1(RS),AL1(0),AL1(E2+S2),AL1(0),X'04' 86       26840000
         DC    CL5'BXLE',AL1(RS),AL1(0),AL1(E2+S2),AL1(0),X'04' 87      26850000
         DC    CL5'SRL',AL1(RS),AL1(0),AL1(0),AL1(ARITH),X'04' 88       26860000
         DC    CL5'SLL',AL1(RS),AL1(0),AL1(0),AL1(ARITH),X'04' 89       26870000
         DC    CL5'SRA',AL1(RS),AL1(0),AL1(0),AL1(ARITH),X'04' 8A       26880000
         DC    CL5'SLA',AL1(RS),AL1(0),AL1(0),AL1(ARITH),X'04' 8B       26890000
         DC    CL5'SRDL',AL1(RS),AL1(0),AL1(EPR),AL1(ARITH),X'04' 8C    26900000
         DC    CL5'SLDL',AL1(RS),AL1(0),AL1(EPR),AL1(ARITH),X'04' 8D    26910000
         DC    CL5'SRDA',AL1(RS),AL1(0),AL1(EPR),AL1(ARITH),X'04' 8E    26920000
         DC    CL5'SLDA',AL1(RS),AL1(0),AL1(EPR),AL1(ARITH),X'04' 8F    26930000
         DC    CL5'STM',AL1(RS),AL1(0),AL1(E4+S2),AL1(0),X'04' 90       26940000
         DC    CL5'TM',AL1(SI),AL1(0),AL1(0),AL1(ARITH),X'04' 91        26950000
         DC    CL5'MVI',AL1(SI),AL1(0),AL1(S2),AL1(0),X'04' 92          26960000
         DC    CL5'TS',AL1(S),AL1(0),AL1(0),AL1(0),X'04' 93             26970000
         DC    CL5'NI',AL1(SI),AL1(0),AL1(0),AL1(ZRO8),X'04' 94         26980000
         DC    CL5'CLI',AL1(SI),AL1(0),AL1(0),AL1(CPR),X'04' 95         26990000
         DC    CL5'OI',AL1(SI),AL1(0),AL1(0),AL1(ZRO8),X'04' 96         27000000
         DC    CL5'XI',AL1(SI),AL1(0),AL1(0),AL1(ZRO8),X'04' 97         27010000
         DC    CL5'LM',AL1(RS),AL1(0),AL1(E4),AL1(0),X'04' 98           27020000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      27030000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      27040000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      27050000
         DC    CL5' ',AL1(TWO),AL1(0),AL1(0),AL1(0),X'04' 9C            27060000
         DC    CL5' ',AL1(TWO),AL1(0),AL1(0),AL1(0),X'04' 9D            27070000
         DC    CL5' ',AL1(TWO),AL1(0),AL1(0),AL1(0),X'04' 9E            27080000
         DC    CL5' ',AL1(TWO),AL1(0),AL1(0),AL1(0),X'04' 9F            27090000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      27100000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      27110000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      27120000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      27130000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      27140000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      27150000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      27160000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      27170000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      27180000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      27190000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      27200000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      27210000
         DC    CL5'STNSM',AL1(SI),AL1(PRIV),AL1(0),AL1(0),X'04' AC      27220000
         DC    CL5'STOSM',AL1(SI),AL1(PRIV),AL1(0),AL1(0),X'04' AD      27230000
         DC    CL5'SIGP',AL1(RS),AL1(PRIV),AL1(0),AL1(0),X'04' AE       27240000
         DC    CL5'MC',AL1(SI),AL1(0),AL1(0),AL1(0),X'04' AF            27250000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      27260000
         DC    CL5'LRA',AL1(RX),AL1(PRIV),AL1(0),AL1(0),X'04' B1        27270000
         DC    CL5' ',AL1(TWO),AL1(0),AL1(0),AL1(0),X'04' B2            27280000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      27290000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      27300000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      27310000
         DC    CL5'STCTL',AL1(RS),AL1(PRIV),AL1(0),AL1(0),X'04' B6      27320000
         DC    CL5'LCTL',AL1(RS),AL1(PRIV),AL1(E4),AL1(0),X'04' B7      27330000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      27340000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      27350000
         DC    CL5'CS',AL1(RS),AL1(0),AL1(E4+EPR),AL1(0),X'04' BA       27360000
         DC    CL5'CDS',AL1(RS),AL1(0),AL1(E4+EPR),AL1(0),X'04' BB      27370000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'04' NOT INSTR      27380000
         DC    CL5'CLM',AL1(RS),AL1(0),AL1(0),AL1(CPR),X'04' BD         27390000
         DC    CL5'STCM',AL1(RS),AL1(0),AL1(S2),AL1(0),X'04' BE         27400000
         DC    CL5'ICM',AL1(RS),AL1(0),AL1(0),AL1(ZRO8),X'04' BF        27410000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      27420000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      27430000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      27440000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      27450000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      27460000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      27470000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      27480000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      27490000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      27500000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      27510000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      27520000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      27530000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      27540000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      27550000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      27560000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      27570000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      27580000
         DC    CL5'MVN',AL1(SS1),AL1(0),AL1(S1),AL1(0),X'06' D1         27590000
         DC    CL5'MVC',AL1(SS1),AL1(0),AL1(S1),AL1(0),X'06' D2         27600000
         DC    CL5'MVZ',AL1(SS1),AL1(0),AL1(S1),AL1(0),X'06' D3         27610000
         DC    CL5'NC',AL1(SS1),AL1(0),AL1(S1),AL1(ZRO8),X'06' D4       27620000
         DC    CL5'CLC',AL1(SS1),AL1(0),AL1(0),AL1(CPR),X'06' D5        27630000
         DC    CL5'OC',AL1(SS1),AL1(0),AL1(S1),AL1(ZRO8),X'06' D6       27640000
         DC    CL5'XC',AL1(SS1),AL1(0),AL1(S1),AL1(ZRO8),X'06' D7       27650000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      27660000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      27670000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      27680000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      27690000
         DC    CL5'TR',AL1(SS1),AL1(0),AL1(S1),AL1(0),X'06' DC          27700000
         DC    CL5'TRT',AL1(SS1),AL1(0),AL1(0),AL1(ZRO8),X'06' DD       27710000
         DC    CL5'ED',AL1(SS1),AL1(0),AL1(S1),AL1(ARITH),X'06' DE      27720000
         DC    CL5'EDMK',AL1(SS1),AL1(0),AL1(S1),AL1(ARITH),X'06' DF    27730000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      27740000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      27750000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      27760000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      27770000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      27780000
         DC    CL5' ',AL1(TWO),AL1(0),AL1(0),AL1(0),X'04' E5            27790005
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      27800000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      27810000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      27820000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      27830000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      27840000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      27850000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      27860000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      27870000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      27880000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      27890000
         DC    CL5'SRP',AL1(SS2),AL1(0),AL1(S1),AL1(ARITH),X'06' F0     27900000
         DC    CL5'MVO',AL1(SS2),AL1(0),AL1(S1),AL1(0),X'06' F1         27910000
         DC    CL5'PACK',AL1(SS2),AL1(0),AL1(S1),AL1(0),X'06' F2        27920000
         DC    CL5'UNPK',AL1(SS2),AL1(0),AL1(S1),AL1(0),X'06' F3        27930000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      27940000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      27950000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      27960000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      27970000
         DC    CL5'ZAP',AL1(SS2),AL1(0),AL1(S1),AL1(ARITH),X'06' F8     27980000
         DC    CL5'CP',AL1(SS2),AL1(0),AL1(0),AL1(CPR),X'06' F9         27990000
         DC    CL5'AP',AL1(SS2),AL1(0),AL1(S1),AL1(ARITH),X'06' FA      28000000
         DC    CL5'SP',AL1(SS2),AL1(0),AL1(S1),AL1(ARITH),X'06' FB      28010000
         DC    CL5'MP',AL1(SS2),AL1(0),AL1(S1),AL1(0),X'06' FC          28020000
         DC    CL5'DP',AL1(SS2),AL1(0),AL1(S1),AL1(0),X'06' FD          28030000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      28040000
         DC    XL5'00',AL1(0),AL1(0),AL1(0),AL1(0),X'06' NOT INSTR      28050000
         DC    X'FFFF'                 TABLE END                        28060000
*                                                                       28070000
*                                                                       28080000
*                                                                       28090000
DBLOP    DS    0CL12                   TWO-BYTE OP-CODE TABLE           28100000
         DC    X'0101',CL5'PR   ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     28110005
         DC    X'0102',CL5'UPT  ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     28120005
         DC    X'9C00',CL5'SIO  ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  28130005
         DC    X'9C01',CL5'SIOF ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  28140005
         DC    X'9D00',CL5'TIO  ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  28150005
         DC    X'9D01',CL5'CLRIO',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  28160005
         DC    X'9E00',CL5'HIO  ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  28170005
         DC    X'9E01',CL5'HDV  ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  28180005
         DC    X'9F00',CL5'TCH  ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  28190005
         DC    X'B202',CL5'STIDP',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  28200005
         DC    X'B203',CL5'STIDC',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  28210005
         DC    X'B204',CL5'SCK  ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  28220005
         DC    X'B205',CL5'STCK ',AL1(S),AL1(0),AL1(E8+S2),AL1(0),X'04' 28230005
         DC    X'B206',CL5'SCKC ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  28240005
         DC    X'B207',CL5'STCKC',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  28250005
         DC    X'B208',CL5'SPT  ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  28260005
         DC    X'B209',CL5'STPT ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  28270005
         DC    X'B20A',CL5'SPKA ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  28280005
         DC    X'B20B',CL5'IPK  ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  28290005
         DC    X'B20D',CL5'PTLB ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  28300005
         DC    X'B210',CL5'SPX  ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  28310005
         DC    X'B211',CL5'STPX ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  28320005
         DC    X'B212',CL5'STAP ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  28330005
         DC    X'B213',CL5'RRB  ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  28340005
         DC    X'B214',CL5'SIE  ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  28350005
         DC    X'B218',CL5'PC   ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     28360005
         DC    X'B219',CL5'SAC  ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     28370005
         DC    X'B21A',CL5'CFC  ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     28380005
         DC    X'B221',CL5'IPTE ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  28390005
         DC    X'B222',CL5'IPM  ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     28400005
         DC    X'B223',CL5'IVSK ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     28410005
         DC    X'B224',CL5'IAC  ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     28420005
         DC    X'B225',CL5'SSAR ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     28430005
         DC    X'B226',CL5'EPAR ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     28440005
         DC    X'B227',CL5'ESAR ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     28450005
         DC    X'B228',CL5'PT   ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     28460005
         DC    X'B229',CL5'ISKE ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  28470005
         DC    X'B22A',CL5'RRBE ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  28480005
         DC    X'B22B',CL5'SSKE ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  28490005
         DC    X'B22C',CL5'TB   ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  28500005
         DC    X'B22D',CL5'DXR  ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     28510005
         DC    X'B230',CL5'CSCH ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  28520005
         DC    X'B231',CL5'HSCH ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  28530005
         DC    X'B232',CL5'MSCH ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  28540005
         DC    X'B233',CL5'SSCH ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  28550005
         DC    X'B234',CL5'STSCH',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  28560005
         DC    X'B235',CL5'TSCH ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  28570005
         DC    X'B236',CL5'TPI  ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  28580005
         DC    X'B237',CL5'SAL  ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  28590005
         DC    X'B238',CL5'RSCH ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  28600005
         DC    X'B239',CL5'STCRW',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  28610005
         DC    X'B23A',CL5'STCPS',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  28620005
         DC    X'B23B',CL5'RCHP ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  28630005
         DC    X'B240',CL5'BAKR ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     28640005
         DC    X'B244',CL5'SQDR ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     28650005
         DC    X'B245',CL5'SQER ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     28660005
         DC    X'B246',CL5'STURA',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  28670005
         DC    X'B247',CL5'MSTA ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     28680005
         DC    X'B248',CL5'PALB ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  28690005
         DC    X'B249',CL5'EREG ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     28700005
         DC    X'B24A',CL5'ESTA ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     28710005
         DC    X'B24B',CL5'LURA ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  28720005
         DC    X'B24C',CL5'TAR  ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     28730005
         DC    X'B24D',CL5'CPYA ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     28740005
         DC    X'B24E',CL5'SAR  ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     28750005
         DC    X'B24F',CL5'EAR  ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     28760005
         DC    X'B254',CL5'MVPG ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     28770005
         DC    X'B255',CL5'MVST ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     28780005
         DC    X'B257',CL5'CUSE ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     28790005
         DC    X'B258',CL5'BSG  ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     28800005
         DC    X'B25D',CL5'CLST ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     28810005
         DC    X'B25E',CL5'SRST ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     28820005
         DC    X'B279',CL5'SACF ',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     28830006
         DC    X'E500',CL5'LASP ',AL1(S),AL1(PRIV),AL1(0),AL1(0),X'04'  28840005
         DC    X'E501',CL5'TPROT',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     28850005
         DC    X'E50E',CL5'MVCSK',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     28860005
         DC    X'E50F',CL5'MVCDK',AL1(S),AL1(0),AL1(0),AL1(0),X'04'     28870005
         DC    X'FFFF'                 TABLE END                        28880000
*                                                                       28890000
*                                                                       28900000
*                                                                       28910000
SVCOP    DS    0CL15                   SVC NAME TABLE                   28920000
         DC    AL1(0),CL14'EXCP/XDAP'                                   28930000
         DC    AL1(1),CL14'WAIT/WAITR'                                  28940000
         DC    AL1(2),CL14'POST/PRTOV'                                  28950000
         DC    AL1(3),CL14'EXIT'                                        28960000
         DC    AL1(4),CL14'GETMAIN'                                     28970000
         DC    AL1(5),CL14'FREEMAIN'                                    28980000
         DC    AL1(6),CL14'LINK'                                        28990000
         DC    AL1(7),CL14'XCTL'                                        29000000
         DC    AL1(8),CL14'LOAD'                                        29010000
         DC    AL1(9),CL14'DELETE'                                      29020000
         DC    AL1(10),CL14'GET/FREEMAIN R'                             29030000
         DC    AL1(11),CL14'TIME'                                       29040000
         DC    AL1(12),CL14'SYNCH'                                      29050000
         DC    AL1(13),CL14'ABEND'                                      29060000
         DC    AL1(14),CL14'SPIE'                                       29070000
         DC    AL1(15),CL14'ERREXCP'                                    29080000
         DC    AL1(16),CL14'PURGE'                                      29090000
         DC    AL1(17),CL14'RESTORE'                                    29100000
         DC    AL1(18),CL14'BLDL/FIND'                                  29110000
         DC    AL1(19),CL14'OPEN'                                       29120000
         DC    AL1(20),CL14'CLOSE'                                      29130000
         DC    AL1(21),CL14'STOW'                                       29140000
         DC    AL1(22),CL14'OPEN TYPE J'                                29150000
         DC    AL1(23),CL14'CLOSE TYPE T'                               29160000
         DC    AL1(24),CL14'DEVTYPE'                                    29170000
         DC    AL1(25),CL14'TRKBAL'                                     29180000
         DC    AL1(26),CL14'LOCATE, ETC'                                29190000
         DC    AL1(27),CL14'OBTAIN'                                     29200000
         DC    AL1(28),CL14'CVOL'                                       29210000
         DC    AL1(29),CL14'SCRATCH'                                    29220000
         DC    AL1(30),CL14'RENAME'                                     29230000
         DC    AL1(31),CL14'FEOV'                                       29240000
         DC    AL1(32),CL14'(NO MACRO)'                                 29250000
         DC    AL1(33),CL14'IOHALT'                                     29260000
         DC    AL1(34),CL14'MGCR/QEDIT'                                 29270000
         DC    AL1(35),CL14'WTO/WTOR'                                   29280000
         DC    AL1(36),CL14'WTL'                                        29290000
         DC    AL1(37),CL14'SEGLD/SEGWT'                                29300000
         DC    AL1(39),CL14'LABEL'                                      29310000
         DC    AL1(40),CL14'EXTRACT'                                    29320000
         DC    AL1(41),CL14'IDENTIFY'                                   29330000
         DC    AL1(42),CL14'ATTACH'                                     29340000
         DC    AL1(43),CL14'CIRB'                                       29350000
         DC    AL1(44),CL14'CHAP'                                       29360000
         DC    AL1(45),CL14'OVLYBRCH'                                   29370000
         DC    AL1(46),CL14'TTIMER'                                     29380000
         DC    AL1(47),CL14'STIMER'                                     29390000
         DC    AL1(48),CL14'DEQ'                                        29400000
         DC    AL1(51),CL14'SNAP/SDUMP'                                 29410000
         DC    AL1(52),CL14'RESTART'                                    29420000
         DC    AL1(53),CL14'RELEX'                                      29430000
         DC    AL1(54),CL14'DISABLE'                                    29440000
         DC    AL1(55),CL14'EOV'                                        29450000
         DC    AL1(56),CL14'ENQ/RESERVE'                                29460000
         DC    AL1(57),CL14'FREEDBUF'                                   29470000
         DC    AL1(58),CL14'RELBUF/REQBUF'                              29480000
         DC    AL1(59),CL14'OLTEP'                                      29490000
         DC    AL1(60),CL14'(E)STAE/STAI'                               29500000
         DC    AL1(61),CL14'IKJEGS6A'                                   29510000
         DC    AL1(62),CL14'DETACH'                                     29520000
         DC    AL1(63),CL14'CHKPT'                                      29530000
         DC    AL1(64),CL14'RDJFCB'                                     29540000
         DC    AL1(66),CL14'BTAMTEST'                                   29550000
         DC    AL1(67),CL14'SYNADAF'                                    29560000
         DC    AL1(68),CL14'SYNADRLS'                                   29570000
         DC    AL1(69),CL14'BSP'                                        29580000
         DC    AL1(70),CL14'GSERV'                                      29590000
         DC    AL1(71),CL14'ASGNBFR, ETC'                               29600000
         DC    AL1(72),CL14'CHATR'                                      29610000
         DC    AL1(73),CL14'SPAR'                                       29620000
         DC    AL1(74),CL14'DAR'                                        29630000
         DC    AL1(75),CL14'DQUEUE'                                     29640000
         DC    AL1(76),CL14'(NO MACRO)'                                 29650000
         DC    AL1(78),CL14'(NO MACRO)'                                 29660000
         DC    AL1(79),CL14'STATUS'                                     29670000
         DC    AL1(81),CL14'SETPRT'                                     29680000
         DC    AL1(82),CL14'DASDR'                                      29690000
         DC    AL1(83),CL14'SMFWTM'                                     29700000
         DC    AL1(84),CL14'GRAPHICS'                                   29710000
         DC    AL1(85),CL14'DDRSWAP'                                    29720000
         DC    AL1(86),CL14'ATLAS'                                      29730000
         DC    AL1(87),CL14'DOM'                                        29740000
         DC    AL1(88),CL14'MOD88'                                      29750000
         DC    AL1(91),CL14'VOLSTAT'                                    29760000
         DC    AL1(92),CL14'TCBEXCP'                                    29770000
         DC    AL1(93),CL14'TGET/TPUT'                                  29780000
         DC    AL1(94),CL14'STCC'                                       29790000
         DC    AL1(95),CL14'SYSEVENT'                                   29800000
         DC    AL1(96),CL14'STAX'                                       29810000
         DC    AL1(97),CL14'TSO TEST'                                   29820000
         DC    AL1(98),CL14'PROTECT'                                    29830000
         DC    AL1(99),CL14'DDDYNAM'                                    29840000
         DC    AL1(100),CL14'IKJEFFIB'                                  29850000
         DC    AL1(101),CL14'QTIP'                                      29860000
         DC    AL1(102),CL14'AQCTL'                                     29870000
         DC    AL1(103),CL14'XLATE'                                     29880000
         DC    AL1(104),CL14'TOPCTL'                                    29890000
         DC    AL1(105),CL14'IMAGLIB'                                   29900000
         DC    AL1(107),CL14'MODESET'                                   29910000
         DC    AL1(109),CL14'ESR TYPE 4'                                29920000
         DC    AL1(110),CL14'DSTATUS'                                   29930000
         DC    AL1(111),CL14'(NO MACRO)'                                29940000
         DC    AL1(112),CL14'PGRLSE'                                    29950000
         DC    AL1(113),CL14'PGFIX ETC'                                 29960007
         DC    AL1(114),CL14'EXCPVR'                                    29970000
         DC    AL1(116),CL14'ESR TYPE 1'                                29980000
         DC    AL1(117),CL14'DEBCHK'                                    29990000
         DC    AL1(119),CL14'TESTAUTH'                                  30000000
         DC    AL1(120),CL14'GETMAIN/FREEMAIN'                          30010000
         DC    AL1(121),CL14'VSAM'                                      30020000
         DC    AL1(122),CL14'EVENTS'                                    30030000
         DC    AL1(123),CL14'PURGEDQ'                                   30040000
         DC    AL1(124),CL14'TPIO'                                      30050000
         DC    AL1(125),CL14'EVENTS'                                    30060000
         DC    AL1(126),CL14'MSS INTERFACE'                             30070000
         DC    X'FF'                   END OF TABLE                     30080000
*                                                                       30090036
CHARTRAN DC    256X'FF'                TRT TABLE FOR CHAR/HEX DETERMINA 30100036
         ORG   CHARTRAN+C' '                                            30110036
         DC    X'00'                   BLANK IS CHARACTER               30120036
         ORG   CHARTRAN+C'a'                                        DSK 30130036
         DC    9X'00'                  a-i ARE CHARACTERS           DSK 30140036
         ORG   CHARTRAN+C'j'                                        DSK 30150036
         DC    9X'00'                  j-r ARE CHARACTERS           DSK 30160036
         ORG   CHARTRAN+C's'                                        DSK 30170036
         DC    8X'00'                  s-z ARE CHARACTERS           DSK 30180036
         ORG   CHARTRAN+C'A'                                            30190036
         DC    9X'00'                  A-I ARE CHARACTERS               30200036
         ORG   CHARTRAN+C'J'                                            30210036
         DC    9X'00'                  J-R ARE CHARACTERS               30220036
         ORG   CHARTRAN+C'S'                                            30230036
         DC    8X'00'                  S-Z ARE CHARACTERS               30240036
         ORG   CHARTRAN+C'0'                                            30250036
         DC    10X'00'                 0-9 ARE CHARACTERS               30260036
         ORG   CHARTRAN+C'¢'                                            30270036
         DC    6X'0'                   ¢.<(+|                           30280036
         ORG   CHARTRAN+C'!'                                            30290036
         DC    8X'0'                   !$*);¬-/                         30300036
         ORG   CHARTRAN+C','                                            30310036
         DC    5X'0'                   ,%_>?                            30320036
         ORG   CHARTRAN+C':'                                            30330036
         DC    X'000000FF0000'         :#@'="                           30340036
         ORG                                                            30350036
         DC    (((((*-UTL31P2)/256)+1)*256)-(*-UTL31P2))X'00'           30360036
UTL31P2Z DC    0D'0'                                                    30370036
******************************************************************      30380036
*                                                                       30390036
* FOLLOWING FIELDS: COMMPARM THRU COMMEND ARE COMMON AREAS SHARED       30400036
* BY THIS, AND CALLED SUB-PROGRAMS. ALL CHANGES MUST BE COORDINTAED     30410036
* WITH ALL OTHER PROGRAMS.                                              30420036
*                                                                       30430036
******************************************************************      30440036
COMMPARM DSECT ,                       COMMON AREAS                     30450036
DBLWD    DS    D                       DOUBLEWORD WORK AREA             30460036
PUNCHDCB DS    F                       @ SYSPUNCH DCB                   30470036
PRINTDCB DS    F                       @ SYSPRINT DCB                   30480036
INDCB    DS    F                       @ SYSIN DCB                      30490036
CSECT    DS    CL8                     SPECIFIED CSECT NAME             30500036
ESDID    DS    XL2                     ESD ID OF SPECIFIED CSECT        30510036
ENDLBLNM DS    CL8                     SYMBOL FOR END STMT BEGIN POINTE 30520036
LINECT   DS    PL2                     PRINT LINE COUNTER               30530036
START    DS    A                       LKED ASSIGNED START ADDR OF CSEC 30540036
END      DS    A                       CSECT END ADDRESS                30550036
LENGTH   DS    F                       LENGTH OF SPECIFIED CSECT        30560036
LBLTBL   DS    F                       @ LABEL TABLE                    30570036
CURRLBL  DS    F                       CURRENT LABEL ENTRY ADDR         30580036
ENDLBL   DS    F                       @ END OF LABEL TBL               30590036
LBLLGTH  DS    AL2                     LENGTH OF LABEL ENTRY            30600036
TXTSTRT  DS    F                       @ TEXT STORAGE AREA              30610036
TXTEND   DS    F                       @ END OF TEXT AREA               30620036
TXTCURR  DS    F                       @ CURRENT TEXT LOC               30630036
DTBCURR  DS    F                       @ CURRENT DSECT TABLE ENTRY      30640036
DTBEND   DS    F                       @ DSECT TABLE END                30650036
DTBSTRT  DS    F                       @ DSECT TABLE START              30660036
USGSTRT  DS    F                       @ USING TABLE START              30670036
USGCUR   DS    F                       @ CURRENT USING TABLE ENTRY      30680036
USGEND   DS    F                       @ USING TABLE END                30690036
DATONLY  DS    F                       @ DATA ONLY TABLE                30700036
DATOCUR  DS    F                       @ CURRENT DATA ONLY ENTRY        30710036
DATEND   DS    F                       @ END OF DATA ONLY TABLE         30720036
PRMOPT   DS    X                                                    DSK 30730036
FLPTASM  EQU   X'80'                   FLOATING POINT INDICATOR     DSK 30740036
PRIVASM  EQU   X'40'                   PRIVILEGED INDICATOR         DSK 30750036
DBGINSTR EQU   X'20'                   DEBUG(INSTR)                 DSK 30760036
DBGCONST EQU   X'10'                   DEBUG(CONST)                 DSK 30770036
DBGNOCMT EQU   X'08'                   DEBUG(NOCMT)                 DSK 30780036
DBGLABEL EQU   X'04'                   DEBUG(LABEL)                 DSK 30790036
CONALHEX EQU   X'02'                   DCNOCHAR                     DSK 30800036
CONNOLOW EQU   X'01'                   DCNOLOWER                    DSK 30810036
         DS    X                                                    DSK 30820036
USERR    DS    XL1                     ERROR INDIC FOR DISASM1          30830036
NBRLBLS  DS    H                       NBR LABELS FROM DISASM1          30840036
*                                                                       30850036
WORKREC  DS    0CL80                   DISASSEMBLY WORK AREA            30860036
NAME     DS    CL8                     NAME                             30870036
         DS    CL1                                                      30880036
MNEMONIC DS    CL5                     INSTRUCTION MNEMONIC             30890036
         DS    CL1                                                      30900036
OPNDS    DS    CL27                    1ST OPERAND                      30910036
         DS    CL1                                                      30920036
COMMENT  DS    CL28                    COMMENT                          30930036
COL72    DS    CL1                     CONTINUATION COLUMN              30940036
SEQNBR   DS    CL8                     CARD SEQUENCE NBR                30950036
*                                                                       30960036
CARDNO   DS    PL4                     CURRENT OUTPUT CARD NBR          30970036
PRTLINE  DS    0CL121                  PRINT LINE                       30980036
PCC      DS    CL1                     CARRIAGE CONTROL                 30990036
PRT      DS    CL120                   PRINT DATA                       31000036
*                                                                       31010036
         DS    0F                                                       31020036
BLDLIST  DS    0CL62                   BLDL LIST                        31030036
         DC    H'1'                    ONE ENTRY                        31040036
         DC    H'58'                   LENGTH OF ENTRY                  31050036
MEMBER   DC    CL8' '                  MEMBER NAME                      31060036
TTRMOD   DC    XL3'000000'             TTR OF MODULE                    31070036
CCAT     DC    XL1'00'                 CONCATENATION NUMBER             31080036
         DC    XL1'00'                                                  31090036
ALIASIND DC    XL1'00'                 ALIAS AND MISC INDICATOR         31100036
*                           80=ALIAS                                    31110036
TTR1TXT  DC    XL3'000000'             TTR OF 1ST TXT RECORD            31120036
         DC    XL1'00'                                                  31130036
TTRNS    DC    XL3'000000'             TTR OF NOTE OR SCATTER LIST      31140036
NNOTE    DC    XL1'00'                 NBR ENTRIES IN NOTE LIST         31150036
ATTR1A   DC    XL1'00'                 MODULE ATTRIBUTES 1, BYTE 1      31160036
*                           80=RENT                                     31170036
*                           40=REUS                                     31180036
*                           20=OVERLAY                                  31190036
*                           10=UNDER TEST                               31200036
*                           08=ONLY LOADABLE                            31210036
*                           04=SCATTER FORMAT                           31220036
*                           02=EXECUTABLE                               31230036
*                           01=ONE TXT, NO RLD RECORDS                  31240036
ATTR1B   DC    XL1'00'                 ATTRIBUTES 1, BYTE 2             31250036
*                           80=CANNOT BE REPROCESSED BY LKED E          31260036
*                           40=ORIGIN OF 1ST TXT RECORD IS ZERO         31270036
*                           20=ASSIGNED ENTRY POINT ADDR IS ZERO        31280036
*                           10=CONTAINS NO RLD RECORD                   31290036
*                           08=CANNOT BE REPROCESSED BY LKED            31300036
*                           04=CONTAINS TESTRAN SYMBOLS                 31310036
*                           02=CREATED BY LKED                          31320036
*                           01=REFR                                     31330036
TOTVIRT  DC    XL3'000000'             TOTAL VIRTUAL STRG REQRD FOR MOD 31340036
LENG1    DC    XL2'0000'               LENGTH OF 1ST TEXT RECORD        31350036
LKEPA    DC    XL3'000000'             ASSIGNED ENTRY POINT ADDR        31360036
ATTR2    DC    XL1'00'                 ATTRIBUTES 2                     31370036
*                           80=PROCESSED BY OS/VS LKED                  31380036
*                           20=PAGE ALIGNMENT REQUIRED FOR MODULE       31390036
*                           10=SSI PRESENT                              31400036
         DC    XL2'0000'                                                31410036
SCTRLEN  DC    XL2'0000'               SCATTER LIST LENGTH              31420036
TTLEN    DC    XL2'0000'               TRANSLATION TABLE LENGTH         31430036
SCESDID  DC    XL2'0000'               CESD NBR FOR 1ST TXT RECD        31440036
SCEPESD  DC    XL2'0000'               CESD NBR FOR ENTRY POINT         31450036
ALEPA    DC    XL3'000000'             ENTRY POINT OF THE MEMBER NAME   31460036
ALMEM    DC    CL8' '                  REAL MEMBER NAME FOR ALIAS       31470036
SSI      DS    XL4'00000000'           SSI BYTES                        31480036
AUTHLEN  DC    XL1'00'                 AUTH CODE LENGTH                 31490036
AUTHCOD  DC    XL1'00'                 AUTH CODE                        31500036
*                                                                       31510036
COMMEND  EQU   *                                                        31520036
******************************************************************      31530036
*                                                                *      31540036
*                                                                *      31550036
*                                                                *      31560036
******************************************************************      31570036
LABELD   DSECT ,                       LABEL TABLE ENTRY                31580036
LABEL    DS    0CL13                   13-BYTE ENTRIES                  31590036
LBLADR   DS    XL3                     RELATIVE ADDR IN TEXT            31600036
LBLTYP   DS    CL1                     TYPE:                            31610047
LBLTYPL  EQU   C'L'                          L=LABEL                    31620050
LBLTYPA  EQU   C'A'                          A=ADCON                    31630047
LBLTYPV  EQU   C'V'                          V=VCON                     31640047
LBLTYPW  EQU   C'W'                          W=WXTRN                    31650047
LBLTYPU  EQU   C'U'                          U=USER LABEL               31660047
LBLNAME  DS    CL8                     NAME (SYMBOL)                    31670036
LBLLEN   DS    XL1                     LENGTH IF A, V, OR W             31680036
******************************************************************      31690036
*                                                                *      31700036
*                                                                *      31710036
*                                                                *      31720036
******************************************************************      31730036
USINGD   DSECT ,                       USING TABLE ENTRY                31740036
USING    DS    0CL11                                                    31750036
USBGN    DS    XL3                     OFFSET TO BEGINNING OF RANGE     31760036
USEND    DS    XL3                     OFFSET TO END OF RANGE           31770036
USREG    DS    XL1                     BASE REGISTER USED               31780036
USTYPE   DS    XL1                     TYPE:P=PGM,D=DSECT               31790036
USVALU   DS    XL3                     BASE REG VALUE                   31800036
******************************************************************      31810036
*                                                                *      31820036
*                                                                *      31830036
*                                                                *      31840036
******************************************************************      31850036
DSECTD   DSECT ,                       DSECT FIELD TABLE ENTRY          31860036
DSECT    DS    0CL13                                                    31870036
DSOFSET  DS    XL3                     OFFSET TO 1ST BYTE OF FIELD      31880036
DSLBTYP  DS    CL1                     LABEL TYPE = L                   31890036
DSNAME   DS    CL8                     FIELD NAME                       31900036
DSLENG   DS    XL1                     FIELD LENGTH                     31910036
****************************************************************        31920036
*                                                              *        31930036
*                                                              *        31940036
*                                                              *        31950036
****************************************************************        31960036
DTBD     DSECT ,                       DSECT TABLE ENTRY                31970036
DTB      DS    0CL11                                                    31980036
DTBNAM   DS    XL8                     DSECT NAME                       31990036
DTBFLD@  DS    AL3                     DSECT FIELD TABLE ADDRESS        32000036
****************************************************************        32010038
*                                                              *        32020038
*                                                              *        32030038
*                                                              *        32040038
****************************************************************        32050038
DTAD     DSECT ,                       DATA TABLE ENTRY                 32060038
DTA      DS    0XL6                                                     32070038
DTABGN   DS    AL3                     DATA begin offset                32080038
DTAEND   DS    AL3                     DATA end offset                  32090038
         END                                                            32100000
