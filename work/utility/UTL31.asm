         TITLE '***** DISASSEMBLY PHASE 0 *****'                        00010026
*                                                                       00020021
*DISASSEMBLER PROGRAM TO CREATE AN ASSEMBLER SOURCE PROGRAM             00030000
*FROM A LOAD MODULE IN A PDS. DD CARDS REQUIRED INCLUDE                 00040000
*SYSPRINT FOR MESSAGES AND DIAGNOSTICS USING BLKSIZE A MULTIPLE         00050000
*OF 121, SYSLIB SPECIFYING THE PDS CONTAINING THE MEMBER,        FIX*** 00060000
*WHICH MUST BE A PDS, SYSPUNCH FOR THE ASSEMBLER SOURCE                 00070000
*PROGRAM, HAVING BLKSIZE A MULTIPLE OF 80, AND SYSIN                    00080000
*FOR THE CONTROL CARD INPUT. CONTROL INPUT MAY OPTIONALLY               00090000
*BE ENTERED VIA THE PARM ON THE EXECUTE CARD. CONTROL                   00100000
*INFORMATION INCLUDES THE MEMBER NAME AND CSECT NAME                    00110000
*TO BE DISASSEMBLED. IF CSECT NAME IS OMITTED, THE CSECT                00120000
*FOR ESD-ID 0001 WILL BE USED.                                          00130000
*                                                                       00140000
*                                                                       00150000
* FILES USED BY THIS PROGRAM INCLUDE THE FOLLOWING:                     00160000
*                                                                       00170000
* DDNAME SYSLIB: RECFM=U. INPUT LOAD MODULE LIBRARY.                    00180000
*                                                                       00190000
* DDNAME SYSPUNCH: RECFM=FB,LRECL=80. OUTPUT FILE CONTAINING            00200000
*                 DISASSEMBLED TEXT. (MAXBLK=18,960)                    00210000
*                                                                       00220000
* DDNAME SYSPRINT: RECFM=FBA,LRECL=121.  PRINTED OUTPUT CONTAINING A    00230000
*                LIST OF THE ESD TABLE, RLD TABLE, AND TEXT.            00240000
*                (MAXBLK=18997)                                         00250000
* DDNAME LOADLIB: (OPTIONAL) NAMES A PDS CONTAINING THE                 00260000
*                 MODULES OF DISASM IF DIFFERENT FROM                   00270000
*                 THE STEPLIB. USED PRIMARILY FOR TSO.                  00280000
*                                                                       00290000
* DDNAME SYSIN: RECFM=FB, LRECL=80. CONTROL CARD INPUT.                 00300000
*                                                                       00310000
*                                                                       00320000
* THE CONTROL CARD PROVIDES THE MEMBER NAME AND CSECT NAME              00330000
* OF THE PROGRAM TO BE DISASSEMBLED. MEMBER NAME IS REQUIRED.           00340000
* IF CSECT NAME IS OMITTED, THE CSECT WITH ESDID 0001 WILL              00350000
* BE USED. FORMAT IS FREE-FORM. MEMBER NAME MUST PRECEDE CSECT          00360000
* NAME. ANY NUMBER OF BLANKS MAY PRECEDE AND FOLLOW MEMBER NAME.        00370000
* A COMMA MAY IMMEDIATELY FOLLOW MEMBER NAME IF DESIRED.                00380000
*                                                                       00390000
*                                                                       00400000
* PARM DATA FROM THE EXECUTE CARD MAY BE USED TO SPECIFY                00410000
* VALIDITY OF PRIVILEGED OR FLOATING POINT INSTRUCTIONS.                00420000
* IF NOT SPECIFIED, PRIVILEGED AND FLOATING POINT OPERATION             00430000
* CODES WILL NOT BE TREATED AS INSTRUCTION OP-CODES. TO                 00440000
* INCLUDE THESE INSTRUCTIONS, CODE:                                     00450000
*     PARM=SUPVR        PRIVILEGED INSTRUCTIONS                         00460010
*     PARM=FLTPT        FLOATING POINT INSTRUCTIONS                     00470010
* OTHER OPTIONS:                                                        00480010
*     PARM=DCNOCHAR     1 BYTE CONSTANTS IN HEX                         00490010
*     PARM=DCNOLOWER    LOWER CASE NOT CONSIDERED CHARACTER CONSTANTS   00500012
*     PARM=DEBUG(INSTR) INSTRUCTION DEBUG INFO                          00510010
*     PARM=DEBUG(CONST) CONSTANT DEBUG INFO                             00520010
*     PARM=DEBUG(NOCMT) NO COMMENTS                                     00530010
*     PARM=DEBUG(LABEL) DUMP LABEL TABLE                                00540010
*                                                                       00550010
*                                                                       00560010
*PROCESSING FLOW:                                                       00570000
* 1. PROCESS THE CONTROL INFORMATION TO OBTAIN THE MEMBER               00580000
*    AND CSECT NAMES.                                                   00590000
* 2. ISSUE BLDL AGAINST SYSLIB TO OBTAIN DIRECTORY INFO FOR             00600000
*    THE MEMBER SPECIFIED. IF THE SPECIFIED MEMBER IS AN                00610000
*    ALIAS, RE-ISSUE A BLDL FOR THE REAL MEMBER. PRINT                  00620000
*    DIRECTORY INFORMATION.                                             00630000
* 3. POINT TO THE MEMBER IN THE SYSLIB PDS, AND PROCESS THE             00640000
*    MEMBER. LOAD MODULES CONTAIN AN EXTERNAL SYMBOL DICTIONARY         00650000
*    FOLLOWED BY TEXT AND RELOCATION DICTIONARY INFORMATION.            00660000
*    ALL ESD INFO FOR THE MODULE PRECEDES THE FIRST CONTROL             00670000
*    RECORD. A CONTROL RECORD PRECEDES EACH BLOCK OF TEXT.              00680000
*    RLD INFO FOR THE TEXT FOLLOWS EACH TEXT BLOCK. PROCESSING          00690000
*    OF LOAD MODULE INFORMATION IS AS FOLLOWS:                          00700000
*    A. BUILD AN EXTERNAL SYMBOL TABLE, USING THE CESD BLOCKS.          00710000
*    B. SEARCH FOR THE DESIRED CSECT AS THE TABLE IS BEING              00720000
*       BUILT. THIS CSECT MUST BE FOUND BEFORE THE FIRST                00730000
*       CONTROL RECORD.                                                 00740000
*    C. READ BLOCKS UNTIL A CONTROL RECORD FOR THE DESIRED              00750000
*       CSECT IS FOUND (BY ESD-ID). WHEN FOUND, SAVE THE                00760000
*       TEXT FOR DISASSEMBLY, AND USE THE FOLLOWING RLD                 00770000
*       INFORMATION TO BUILD A RELOCATION DICTIONARY TO BE USED         00780000
*       DURING DISASSEMBLY.                                             00790000
* 4. DISASSEMBLY USES THE EXTERNAL SYMBOL TABLE, RELOCATION             00800000
*    DICTIONARY, AND TEXT BUILT BY THE PREVIOUS STEPS.                  00810000
*                                                                       00820000
*                                                                       00830000
* AUTHOR R THORNTON - NOV 1977                                          00840000
*                                                                       00850010
*                                                                       00860022
* HISTORY                                                               00870010
* VERSION  DESCRIPTION                                                  00880010
* V2.1 DSK PROCESS PARM=, CHECK FOR OPEN OF FILES AND MORE              00890010
* V2.2 DSK 09/07/2020 SOME BUG FIXES AND PARM=CNOLOWER                  00900029
* V2.3 DSK 10/07/2020 More bug fixes and formatting                     00910029
*                                                                       00920000
UTL31    CSECT ,                       NAME OF PROGRAM                  00930021
*                                                                       00940021
***REGISTER EQUATES***                                                  00950021
*                                                                       00960021
R0       EQU   0                                                        00970021
R1       EQU   1                                                        00980021
R2       EQU   2                                                        00990021
R3       EQU   3                                                        01000021
R4       EQU   4                                                        01010021
R5       EQU   5                                                        01020021
R6       EQU   6                                                        01030021
R7       EQU   7                                                        01040021
R8       EQU   8                                                        01050021
R9       EQU   9                                                        01060021
R10      EQU   10                                                       01070021
R11      EQU   11                                                       01080021
R12      EQU   12                                                       01090021
R13      EQU   13                                                       01100021
R14      EQU   14                                                       01110021
R15      EQU   15                                                       01120021
*                                                                       01130021
*******************  PROGRAM INITIALIZATION  *************************  01140021
*                                                                       01150021
         USING *,R15                                                    01160021
         B     UTL31BGN                                                 01170021
         DROP  R15                                                      01180021
         DC    AL1(L'UTL31ID)                                           01190021
UTL31ID  DC    CL8'UTL31'              PROGRAM ID                       01200021
UTL31BGN DS    0H                                                       01210021
         STM   R14,R12,12(R13)         STORE REGS IN HIGH SAVE AREA     01220021
         LR    R3,R15                  INITIALIZE BASE REG              01230021
         LA    R4,4095(,R3)            INITIALIZE THE SECOND            01240021
         LA    R4,1(,R4)               BASE REGISTER                    01250021
         USING UTL31,R3,R4                                              01260021
*                                                                       01270021
***GET MAIN STORAGE FOR SAVE AREA***                                    01280021
*                                                                       01290021
         LA    R0,72                   GET 72 BYTES                     01300021
         GETMAIN R,LV=(0)              GET A SAVE AREA                  01310021
*                                                                       01320021
***SET UP SAVE AREA POINTERS***                                         01330021
*                                                                       01340021
         ST    R1,8(,R13)              STORE LOW SAVE POINTER           01350021
         ST    R1,8(,R13)              STORE LOW SAVE POINTER           01360021
         ST    R13,4(,R1)              STORE HIGH SAVE POINTER          01370021
         LR    R13,R1                  INITIALIZE SAVE POINTER          01380021
         L     R1,4(,R13)              GET POINTER TO RESTORE PARA REG  01390021
         L     R1,24(,R1)              RESTORE PARAMETER REGISTER       01400021
*                                                                       01410021
         L     R5,=A(COMMPARM)         GET PARM FIELD ADDRESS           01420032
         USING COMMPARM,R5                                              01430032
         L     R12,0(,R1)              GET PARM FIELD ADDRESS           01440013
         RDJFCB LOADLIB                WAS LOADLIB DD CARD INCLUDED DSK 01450010
         LTR   R15,R15                 JFCB READ O.K.                   01460000
         BNZ   OPEN1                   NO, DONT OPEN                    01470000
         OPEN  LOADLIB                 GOT DD CARD, OPEN FILE           01480000
****************************************************************        01490000
*                                                              *        01500000
* GET STORAGE FOR THE SYMBOL TABLE, RLD TABLE, AND DATA-ONLY   *        01510000
* TABLES, AND OPEN FILES.                                      *        01520000
*                                                              *        01530000
****************************************************************        01540000
OPEN1    DS    0H                                                       01550018
         OPEN  (SYSPRINT,OUTPUT,SYSPUNCH,OUTPUT)                        01560018
         LA    R2,8                    INCASE OPEN FAILED           DSK 01570010
         TM    SYSPRINT+48,X'10'       DID SYSPRINT OPEN O.K.       DSK 01580010
         BZ    CLOSES                  NO                           DSK 01590010
         TM    SYSPUNCH+48,X'10'       DID SYSPUNCH OPEN O.K.       DSK 01600010
         BZ    CLOSES                  NO                           DSK 01610010
         MVC   PRT(30),=C'Disassembler UTL31 Version 2.3'           DSK 01620029
         BAL   R9,PRINT                GO PRINT MESSAGE             DSK 01630010
         MVC   PRT(5),=C'PARM='        MOVE PARAMETER INFO LITERAL  DSK 01640012
         CLI   1(R12),0                ANY PARAMETER?               DSK 01650012
         BE    PRMPRT                  NO, SKIP MOVE                DSK 01660012
         LH    R1,0(,R12)              GET PARMETER LENGTH          DSK 01670012
         BCTR  R1,0                    MAKE MACHINE LENGTH          DSK 01680012
         EX    R1,PRMMVC               MOVE PARM TO PRINT LINE      DSK 01690012
         B     PRMPRT                  SKIP MOVE                    DSK 01700012
PRMMVC   MVC   PRT+5(0),2(R12)         EXECUTED PARM MOVE           DSK 01710012
PRMPRT   DS    0H                                                   DSK 01720012
         BAL   R9,PRINT                PRINT A LINE                 DSK 01730012
****************************************************************    DSK 01740010
*                                                              *    DSK 01750010
* PROCESS THE PARM FIELD, IF ANY.                              *    DSK 01760010
*                                                              *    DSK 01770010
****************************************************************    DSK 01780010
         SR    R1,R1                   CLEAR WORK REG               DSK 01790010
         ICM   R1,3,0(R12)             PICK UP PARM LENGTH          DSK 01800010
         BZ    PRMDONE                 NO PARM INFO ENTERED         DSK 01810010
         LA    R12,2(,R12)             PARM DATA                    DSK 01820010
PRMSCN   DS    0H                                                   DSK 01830010
         LTR   R1,R1                   ANY DATA LEFT                DSK 01840010
         BE    PRMDONE                 NO, DONE                     DSK 01850010
         CLI   0(R12),C','             DELIMITER                    DSK 01860010
         BNE   PRMCHK                  NO, CHECK PARAMETER          DSK 01870010
         LA    R12,1(,R12)             SKIP PAST COMMA              DSK 01880010
         BCTR  R1,0                    DECREMENT FOR COMMA          DSK 01890010
         B     PRMSCN                  CONTINUE SCAN                DSK 01900010
PRMCHK   DS    0H                                                   DSK 01910010
         CH    R1,=H'+5'               AT LEAST 5 CHARACTERS LEFT   DSK 01920010
         BL    BADPARM                 NO, ERROR                    DSK 01930010
         CLC   =C'SUPVR',0(R12)        PRIVILEGED INSTRUCTIONS      DSK 01940010
         BE    PRMSUP                  YES, SET PRIVILEGED          DSK 01950010
         CLC   =C'FLTPT',0(R12)        FLOATING POINT INSTRUCTIONS  DSK 01960010
         BE    PRMFLT                  YES, SET FLOATING POINT      DSK 01970010
         CH    R1,=H'+8'               AT LEAST 8 CHARACTERS LEFT   DSK 01980011
         BL    BADPARM                 NO, ERROR                    DSK 01990010
         CLC   =C'DCNOCHAR',0(R12)     DCNOCHAR                     DSK 02000010
         BE    PRMDCH                  YES, HANDLE IT               DSK 02010010
         CH    R1,=H'+9'               AT LEAST 9 CHARACTERS LEFT   DSK 02020011
         BL    BADPARM                 NO, ERROR                    DSK 02030011
         CLC   =C'DCNOLOWER',0(R12)    DCNOLOWER                    DSK 02040011
         BE    PRMDNL                  YES, HANDLE IT               DSK 02050011
         CH    R1,=H'+12'              AT LEAST 12 CHARACTERS LEFT  DSK 02060010
         BL    BADPARM                 NO, ERROR                    DSK 02070010
         CLC   =C'DEBUG(',0(R12)       DEBUG                        DSK 02080010
         BE    PRMDBG                  YES, HANDLE DEBUG            DSK 02090010
         B     BADPARM                 PARAMETER INVALID            DSK 02100010
PRMSUP   DS    0H                                                   DSK 02110010
         OI    PRMOPT,PRIVASM          SET PRIVILEGED INSTR O.K.    DSK 02120010
         LA    R12,5(,R12)             SKIP PAST PARAMETER          DSK 02130010
         SH    R1,=H'+5'               DECREMENT FOR PARAMETER      DSK 02140010
         B     PRMSCNC                 NEXT PARAMETER               DSK 02150010
PRMFLT   DS    0H                                                   DSK 02160010
         OI    PRMOPT,FLPTASM          SET FLOATING POINT O.K. .    DSK 02170010
         LA    R12,5(,R12)             SKIP PAST PARAMETER          DSK 02180010
         SH    R1,=H'+5'               DECREMENT FOR PARAMETER      DSK 02190010
         B     PRMSCNC                 NEXT PARAMETER               DSK 02200010
PRMDCH   DS    0H                                                   DSK 02210010
         OI    PRMOPT,CONALHEX         SET DC ARE ALL IN HEX        DSK 02220010
         LA    R12,8(,R12)             SKIP PAST PARAMETER          DSK 02230010
         SH    R1,=H'+8'               DECREMENT FOR PARAMETER      DSK 02240010
         B     PRMSCNC                 NEXT PARAMETER               DSK 02250010
PRMDNL   DS    0H                                                   DSK 02260011
         OI    PRMOPT,CONNOLOW         SET DC CONSTANTS NO LOWER    DSK 02270011
         LA    R12,9(,R12)             SKIP PAST PARAMETER          DSK 02280011
         SH    R1,=H'+9'               DECREMENT FOR PARAMETER      DSK 02290011
         B     PRMSCNC                 NEXT PARAMETER               DSK 02300011
PRMDBG   DS    0H                                                   DSK 02310010
         LA    R12,6(,R12)             SKIP PAST PARAMETER          DSK 02320010
         SH    R1,=H'+6'               DECREMENT FOR PARAMETER      DSK 02330010
PRMDBGNX DS    0H                                                   DSK 02340010
         CLI   0(R12),C')'             END OF DEBUG                 DSK 02350010
         BE    PRMDBGND                                             DSK 02360010
         CLC   =C'INSTR',0(R12)        INSTRUCTION DEBUG INFO       DSK 02370010
         BE    PRMDBGI                                              DSK 02380010
         CLC   =C'CONST',0(R12)        CONSTANT DEBUG INFO          DSK 02390010
         BE    PRMDBGC                                              DSK 02400010
         CLC   =C'NOCMT',0(R12)        NO COMMENTS                  DSK 02410010
         BE    PRMDBGNC                                             DSK 02420010
         CLC   =C'LABEL',0(R12)        DUMP LABEL TABLE             DSK 02430010
         BE    PRMDBGLT                                             DSK 02440010
         B     BADPARM                 PARAMETER INVALID            DSK 02450010
PRMDBGI  DS    0H                                                   DSK 02460010
         OI    PRMOPT,DBGINSTR         SET INSTRUCTION DEBUG        DSK 02470010
         LA    R12,5(,R12)             SKIP PAST PARAMETER          DSK 02480010
         SH    R1,=H'+5'               DECREMENT FOR PARAMETER      DSK 02490010
         B     PRMDBGSC                NEXT PARAMETER               DSK 02500010
PRMDBGC  DS    0H                                                   DSK 02510010
         OI    PRMOPT,DBGCONST         SET CONSTANT DEBUG           DSK 02520010
         LA    R12,5(,R12)             SKIP PAST PARAMETER          DSK 02530010
         SH    R1,=H'+5'               DECREMENT FOR PARAMETER      DSK 02540010
         B     PRMDBGSC                NEXT PARAMETER               DSK 02550010
PRMDBGNC DS    0H                                                   DSK 02560010
         OI    PRMOPT,DBGNOCMT         SET NO COMMENTS              DSK 02570010
         LA    R12,5(,R12)             SKIP PAST PARAMETER          DSK 02580010
         SH    R1,=H'+5'               DECREMENT FOR PARAMETER      DSK 02590010
         B     PRMDBGSC                NEXT PARAMETER               DSK 02600010
PRMDBGLT DS    0H                                                   DSK 02610010
         OI    PRMOPT,DBGLABEL         SET LABVEL TABLE DUMP        DSK 02620010
         LA    R12,5(,R12)             SKIP PAST PARAMETER          DSK 02630010
         SH    R1,=H'+5'               DECREMENT FOR PARAMETER      DSK 02640010
         B     PRMDBGSC                NEXT PARAMETER               DSK 02650010
PRMDBGSC DS    0H                                                   DSK 02660010
         LTR   R1,R1                   ANY PARAMETER DATA LEFT      DSK 02670010
         BE    PRMDONE                 NO, DONE WITH PARMS          DSK 02680010
         CLI   0(R12),C','             DELIMITER                    DSK 02690010
         BE    PRMSCNCM                YES, PROCESS IT              DSK 02700010
         CLI   0(R12),C')'             DELIMITER                    DSK 02710010
         BE    PRMDBGND                YES, PROCESS IT              DSK 02720010
         B     BADPARM                 PARAMETER INVALID            DSK 02730010
PRMSCNCM DS    0H                                                   DSK 02740010
         LA    R12,1(,R12)             SKIP PAST PARAMETER          DSK 02750010
         SH    R1,=H'+1'               DECREMENT FOR PARAMETER      DSK 02760010
         LTR   R1,R1                   ANY PARAMETER DATA LEFT      DSK 02770010
         BE    PRMDONE                 NO, DONE WITH PARMS          DSK 02780010
         B     PRMDBGNX                NEXT DEBUG PARAMETER         DSK 02790010
PRMDBGND DS    0H                                                   DSK 02800010
         LA    R12,1(,R12)             SKIP PAST PARAMETER          DSK 02810010
         SH    R1,=H'+1'               DECREMENT FOR PARAMETER      DSK 02820010
PRMSCNC  DS    0H                                                   DSK 02830010
         LTR   R1,R1                   ANY PARAMETER DATA LEFT      DSK 02840010
         BE    PRMDONE                 NO, DONE WITH PARMS          DSK 02850010
         CLI   0(R12),C','             DELIMITER                    DSK 02860010
         BE    PRMSCN                  YES, PROCESS IT              DSK 02870010
BADPARM  DS    0H                                                   DSK 02880010
         MVC   PRT(13),=C'Invalid PARM='                            DSK 02890027
         BAL   R9,PRINT                PRINT ERROR MESSAGE          DSK 02900010
         B     TERMINAT                                             DSK 02910010
PRMDONE  DS    0H                                                   DSK 02920010
         OPEN  (SYSLIB,,SYSIN)         OPEN FILES                       02930000
         TM    SYSIN+48,X'10'          DID SYSIN OPEN O.K.              02940000
         BZ    NOCTL                   NO                               02950000
         TM    SYSLIB+48,X'10'         DID SYSLIB OPEN O.K.         DSK 02960010
         BZ    NOLIB                   NO                           DSK 02970010
         BAL   R9,GETCTL               EXTRACT DESIRED MEMBER AND CSECT 02980000
         BAL   R9,BLDL                 ISSUE BLDL AND PRINT             02990000
         MVI   CCAT,0                  INSURE TTR0                      03000000
         POINT SYSLIB,TTRMOD           POINT TO 1ST BLOCK OF MODULE     03010000
         GETMAIN R,LV=32768            GET BUFFER STORAGE           DSK 03020006
         ST    R1,BUFAD                SAVE BUFFER ADDRESS              03030000
         GETMAIN R,LV=95000            GET SYMBOL TABLE STORAGE         03040000
         ST    R1,SYMTBAD              SAVE SYMBOL TABLE ADDRESS        03050000
         ST    R1,CURRSYM              SAVE CURRENT SYMBOL ADDR         03060000
         MVI   0(R1),X'FF'             TABLE END INDIC                  03070000
         A     R1,ENDSYM               COMPUTE END ADDR                 03080000
         ST    R1,ENDSYM               STORE TBL END ADDR               03090000
         GETMAIN R,LV=60000            GET RLD TABLE STORAGE            03100000
         ST    R1,RLDTBL               SAVE RLD TABLE ADDRESS           03110000
         ST    R1,CURRLD               SAVE CURRENT RLD ADDR            03120000
         MVI   0(R1),X'FF'             TABLE END INDIC                  03130000
         A     R1,ENDRLD               COMPUTE END ADDR                 03140000
         ST    R1,ENDRLD               STORE TBL END ADDR               03150000
         GETMAIN R,LV=257*L'DTA        GET DATA ONLY TABLE STORAGE  DSK 03160016
         ST    R1,DATONLY              SAVE TBL ADDRESS                 03170000
         USING DTA,R1                                               DSK 03180016
         MVC   DTABGN,HIVAL            SET END VALUE                DSK 03190016
         DROP  R1                                                   DSK 03200016
         ST    R1,DATOCUR              SET CURRENT ADDRESS              03210000
         A     R1,=A(257*L'DTA)        COMPUTE TABLE END ADDR       DSK 03220016
         ST    R1,DATOEND              SAVE END ADDR                DSK 03230016
         BAL   R9,PRINT                PRINT                        DSK 03240010
         MVC   PRT+17(33),=C'***** External Symbol Table *****'     DSK 03250028
         BAL   R9,PRINT                PRINT                            03260000
         MVC   PRT(L'SYMHDR),SYMHDR    SYM TBL HEADER               DSK 03270010
         BAL   R9,PRINT                PRINT                            03280000
****************************************************************        03290000
*                                                              *        03300000
* MAINLINE PROCESSING FOR THE LOAD MODULE. THE DIRECTORY ENTRY *        03310000
* AND TEXT ARE PROCESSED.                                      *        03320000
*                                                              *        03330000
****************************************************************        03340000
MAINLINE DS    0H                      MAINLINE ROUTINE                 03350013
         L     R6,BUFAD                GET BUFFER ADDRESS               03360000
         READ  DECB,SF,SYSLIB,(6),'S'  READ BLOCK FROM MEMBER           03370000
         CHECK DECB                    AWAIT COMPLETION                 03380000
         CLI   0(R6),X'20'             CESD RECORD                      03390000
         BNE   TESTOTHR                NO                               03400000
         BAL   R9,CESDREC              PROCESS CESD RECORDS             03410000
         B     MAINLINE                GO READ AGAIN                    03420000
TESTOTHR DS    0H                                                       03430018
         LA    R9,CNTLRECS             ASSUME CONTROL RECORD            03440018
         CLI   0(R6),1                 IT IS CONTROL                    03450000
         BE    PERFORM                 YES                              03460000
         CLI   0(R6),5                 IS IT CONTROL                    03470000
         BE    PERFORM                 YES                              03480000
         CLI   0(R6),13                IS IT CONTROL                    03490000
         BE    PERFORM                 YES                              03500000
         LA    R9,RLDRECS              ASSUME RLD RECORD                03510000
         CLI   0(R6),2                 IS IT RLD                        03520000
         BE    PERFORM                 YES                              03530000
         CLI   0(R6),6                 IS IT RLD                        03540000
         BE    PERFORM                 YES                              03550000
         CLI   0(R6),14                IS IT RLD                        03560000
         BE    PERFORM                 YES                              03570000
         LA    R9,CTRLRECS             ASSUME CONTROL AND RLD           03580000
         CLI   0(R6),3                 IS IT CTL AND RLD                03590000
         BE    PERFORM                 YES                              03600000
         CLI   0(R6),7                 IS IT CTL AND RLD                03610000
         BE    PERFORM                 YES                              03620000
         CLI   0(R6),15                IS IT CTL AND RLD                03630000
         BE    PERFORM                 YES                              03640000
         B     MAINLINE                NONE OF THESE, SKIP              03650000
PERFORM  DS    0H                                                       03660018
         TM    PROCESS,X'80'           WAS CSECT FOUND                  03670018
         BZ    MISSCS                  NO, ERROR                        03680000
         BALR  R9,R9                   PERFORM APPROPRIATE ROUTINE      03690000
         TM    PROCESS,X'40'           MODULE PROCESSING DONE           03700000
         BZ    MAINLINE                NO, GO READ AGAIN                03710000
         MVI   EOFSW+1,0               SET END OF FILE SWITCH           03720000
         B     ENDINIT                 GO COMPLETE PROCESSING           03730000
****************************************************************        03740000
*                                                              *        03750000
* PROCESS LOAD MODULE CONTROL RECORDS. THESE RECORDS PRECEDE   *        03760000
* TEXT RECORDS, WHICH ARE READ AND PLACED IN STORAGE IN CONTIG-*        03770000
* UOUS LOCATIONS SO THAT THE TEXT FOR THE DESIRED CSECT WILL   *        03780000
* ALL BE IN STORAGE FOR THE REMAINDER OF DISASSEMBLY.          *        03790000
*                                                              *        03800000
****************************************************************        03810000
CNTLRECS DS    0H                      CONTROL RECORD PROCESSING        03820013
         ST    R9,CT9                  SAVE RETURN ADDR                 03830000
         SR    R8,R8                   CLEAR WORK                       03840000
         ICM   R8,7,9(R6)              LKED ASGND @ OF TXT              03850000
         TM    0(R6),X'08'             RECORD PRECEDES LAST RECORD OF M 03860000
         BZ    CNCKTYP                 NO                               03870000
         OI    PROCESS,X'40'           YES, SHOW PROCESSING COMPLETE    03880000
CNCKTYP  DS    0H                                                       03890018
         TM    0(R6),X'02'             CONTROL AND RLD                  03900018
         BO    CNPASRLD                YES                              03910000
         LA    R12,16(,R6)             @ CESD ENTRY NBR                 03920013
         B     CNCKESD                 CONTINUE                         03930000
CNPASRLD DS    0H                                                       03940018
         LH    R12,6(,R6)              GET RLD SECTION LENGTH           03950018
         LA    R12,16(R6,R12)          @ CESD ENTRY NBR                 03960000
CNCKESD  DS    0H                                                       03970018
         LH    R11,4(,R6)              LENGTH OF CONTROL INFO SECTION   03980018
         SRL   R11,2                   COMPUTE NBR CNTL ENTRIES         03990000
         SR    R10,R10                 OFFSET TO 1ST BYTE               04000000
         SR    R9,R9                   LENGTH OF TEXT                   04010000
CNCKESD1 DS    0H                                                       04020018
         CLC   ESDID,0(R12)            THIS THE DESIRED ESD   FIX***    04030018
         BE    CNFNDIT                 YES                              04040000
         AH    R10,2(,R12)             MAINTAIN OFFSET TO 1ST TEXT BYTE 04050013
         LA    R12,4(,R12)             TO NEXT CNTL ENTRY               04060013
         BCT   R11,CNCKESD1            LOOP THRU CNTL ENTRIES  FIX***   04070000
         B     READTEXT                GO READ FOLLOWING TEXT           04080000
CNFNDIT  DS    0H                                                       04090018
         LH    R9,2(,R12)              GET TEXT LENGTH                  04100018
READTEXT DS    0H                                                       04110018
         READ  DECB,SF,,(6),MF=E       READ FOLLOWING TEXT RECORD       04120018
         CHECK DECB                    AWAIT COMPLETION                 04130000
         LTR   R9,R9                   DOES IT CONTAIN DESIRED TEXT     04140000
         BZ    CTXIT                   NO, SKIP IT                      04150000
         S     R8,START                (-) OFFSET IN MODULE    FIX***   04160000
         AR    R8,R10                  ADD OFFSET OF PORTION IN RCD  ** 04170000
*        R8 SHOULD NOW CONTAIN THE OFFSET WITHIN THE CSECT              04180027
*        THAT THIS BLOCK CONTAINS (TRICKY).                             04190027
         A     R10,BUFAD               @ 1ST TEXT BYTE                  04200000
         A     R8,TXTSTRT              @ PLACE TO MOVE TEXT             04210000
         LR    R11,R9                  COPY LENGTH TO MOVE              04220000
         MVCL  R8,R10                  MOVE TEXT TO STORAGE             04230000
CTXIT    DS    0H                                                       04240018
         L     R9,CT9                  GET RETURN ADDR                  04250018
         BR    R9                      EXIT                             04260000
****************************************************************        04270000
*                                                              *        04280000
* PROCESS RLD RECORDS. A TABLE OF RLD DATA IS BUILT WHICH WILL *        04290000
* LATER BE USED TO BUILD PROGRAM LABELS AND ADCONS.            *        04300000
*                                                              *        04310000
****************************************************************        04320000
RLDRECS  DS    0H                      RLD RECORD PROCESSING            04330013
         TM    0(R6),X'08'             LAST RECORD OF MODULE            04340000
         BZ    RLSV9                   NO                               04350000
         OI    PROCESS,X'40'           SHOW PROCESSING COMPLETE         04360000
RLSV9    DS    0H                                                       04370018
         ST    R9,RL9                  SAVE RETURN ADDR                 04380018
RLDSW    DS    0H                                                       04390018
         NOP   RLDST                   FIRST TIME SWITCH                04400018
         MVI   RLDSW+1,C'0'            RESET 1ST TIME SW                04410000
         BAL   R9,PRINT                PRINT                        DSK 04420010
         MVC   PRT+20(20),=C'***** RLD Info *****'                  DSK 04430028
         BAL   R9,PRINT                PRINT                            04440000
         MVC   PRT(L'RLDHDR),RLDHDR    RLD HEADER                   DSK 04450010
         BAL   R9,PRINT                PRINT RLD HEADER                 04460000
RLDST    DS    0H                                                       04470018
         LH    R8,6(,R6)               NBR BYTES OF RLD DATA            04480018
         LA    R6,16(,R6)              @ 1ST BYTE OF RLD DATA           04490013
         AR    R8,R6                   END OF RLD DATA ADDR             04500000
         L     R7,CURRLD               @ NEXT RLD TBL ENTRY             04510000
         USING RLDTBLD,R7                                               04520000
         LH    R10,0(,R6)              RELOCATION POINTER               04530013
         LH    R11,2(,R6)              POSITION POINTER                 04540013
         LA    R6,4(,R6)               PASS POINTERS                    04550013
RLDNXT   DS    0H                                                       04560018
         CLC   1(3,R6),START+1         RLD ADDR BELOW CSECT             04570018
         BL    RLDSTEP                 LOW, IGNORE                      04580000
         CLC   1(3,R6),END+1           RLD ADDR ABOVE CSECT             04590000
         BH    RLDSTEP                 HIGH, IGNORE                     04600000
         C     R7,ENDRLD               END OF RLD TBL                   04610000
         BE    RLDFULL                 YES, ERROR                       04620000
         STH   R10,RLDRP               SAVE RELOC PTR                   04630000
         STH   R11,RLDPP               POS PTR                          04640000
         PACK  RLDTYPE,0(1,R6)         INVERT FLAG BYTE                 04650000
         NI    RLDTYPE,X'0F'           CLEAR HI-ORDER                   04660000
         CLI   RLDTYPE,9               UNRESOLVED                       04670000
         BNE   RLDMOVLN                NO                               04680000
         MVI   RLDTYPE,8               YES, USE PREFERRED VALUE         04690000
RLDMOVLN DS    0H                                                       04700018
         MVC   RLDLEN,0(R6)            FLAG BYTE                        04710018
         NI    RLDLEN,X'0F'            CLEAR HI-ORDER                   04720000
         SR    R12,R12                 CLEAR WORK                       04730000
         IC    R12,RLDLEN              PICK UP BYTE                     04740000
         SRL   R12,2                   SHIFT OUT DIR, IND BITS          04750000
         LA    R12,1(,R12)             ADD 1 = LENGTH                   04760013
         STC   R12,RLDLEN              LENGTH CODE                      04770000
         MVI   RLDDIR,C'+'             ASSUME POS RELOC                 04780000
         TM    0(R6),2                 IS IT POSITIVE                   04790000
         BZ    RLADMV                  YES                              04800000
         MVI   RLDDIR,C'-'             NO, SHOW NEGATIVE                04810000
RLADMV   DS    0H                                                       04820018
         SR    R1,R1                   CLEAR WORK REG                   04830018
         ICM   R1,7,1(R6)              PICK UP ADDRESS                  04840000
         S     R1,START                RELATIVIZE WITHIN CSECT          04850000
         STCM  R1,7,RLDADDR            SAVE RELATIVE ADDRESS            04860000
         LA    R12,RLDRP               @ RELOC PTR                      04870000
         BAL   R9,HEXPRT2              CONVERT                          04880000
         MVC   PRT+6(4),PRTABL         RELOC PTR                        04890000
         LA    R12,RLDPP               @ POS PTR                        04900000
         BAL   R9,HEXPRT2              CONVERT                          04910000
         MVC   PRT+14(4),PRTABL        POS PTR                          04920000
         MVC   PRT+24(4),=C'ACON'      ASSUME A TYPE ADCON              04930000
         CLI   RLDTYPE,0               IS IT ADCON                      04940000
         BE    RLDLN                   YES                              04950000
         MVC   PRT+24(4),=C'VCON'      ASSUME VCON                      04960000
         CLI   RLDTYPE,1               IS IT VCON                       04970000
         BE    RLDLN                   YES                              04980000
         MVC   PRT+22(6),=C'PRDISP'    ASSUME PSEUDO REG DISPL          04990000
         CLI   RLDTYPE,2               IS IT P.R. DISPL                 05000000
         BE    RLDLN                   YES                              05010000
         MVC   PRT+22(6),=C'PRCUM'     ASSUME PSEUDO REG CUMUL DISPL    05020000
         CLI   RLDTYPE,3               IS IT P.R. CUM DISPL             05030000
         BE    RLDLN                   YES                              05040000
         MVC   PRT+21(10),=C'UNRESOLVED' ASSUME UNRESOLVED              05050000
         CLI   RLDTYPE,8               IS IT UNRESOLVED                 05060000
         BE    RLDLN                   YES                              05070000
         MVC   PRT+21(10),BLANX        CLEAR FIELD                      05080000
         MVC   PRT+21(2),=C'?:'                                         05090028
         LA    R12,RLDTYPE             @ TYPE                           05100000
         BAL   R9,HEXPRT1              CONVERT                          05110000
         MVC   PRT+23(1),PRTABL+1      TYPE                             05120028
RLDLN    DS    0H                                                       05130018
         MVC   PRT+35(1),RLDLEN        LENGTH                           05140018
         OI    PRT+35,C'0'             CLEAR ZONE                       05150000
         MVC   PRT+42(1),RLDDIR        RELOCATION DIRECTION             05160000
         LA    R12,RLDADDR             @ ADDRESS                        05170000
         BAL   R9,HEXPRT3              CONVERT                          05180000
         MVC   PRT+46(6),PRTABL        ADDRESS                          05190000
         XC    RLDNAME(9),RLDNAME      CLEAR                            05200000
         LH    R15,RLDRP               GET RELOCATION POINTER           05210000
         BCTR  R15,R0                  DEDUCT 1                         05220000
         LTR   R15,R15                 TEST DIFFERENCE                  05230000
         BM    RLPRT                   NEG, ERROR                       05240000
         MH    R15,=AL2(L'SYMENT)      TIMES SYM TBL ENTRY LENG         05250025
         A     R15,SYMTBAD             @ ESD SYMBOL TBL ENTRY           05260000
         C     R15,CURRSYM             PAST END OF TABLE                05270000
         BH    RLPRT                   YES, ERROR                       05280000
         USING SYMTBL,R15                                               05290000
         MVC   RLDNAME,EXTSYM          ESD SYMBOL TO RLD TBL ENTRY      05300000
         MVC   RLDESDTP,TYPSYM         ESD TYPE TO RLD ENTRY            05310000
         DROP  R15                                                      05320000
         MVC   PRT+60(8),RLDNAME       NAME TO PRINT                    05330000
         MVC   PRT+70(2),=C'LR'        ASSUME LR                        05340000
         CLI   RLDESDTP,3              IS IT LR                         05350000
         BE    RLPRT                   YES                              05360000
         MVC   PRT+70(2),=C'SD'        ASSUME SD                        05370000
         CLI   RLDESDTP,0              IS IT SD                         05380000
         BE    RLPRT                   YES                              05390000
         MVC   PRT+70(2),=C'ER'        ASSUME ER                        05400000
         CLI   RLDESDTP,2              IS IT ER                         05410000
         BE    RLPRT                   YES                              05420000
         MVC   PRT+70(2),=C'PC'        ASSUME PC                        05430000
         CLI   RLDESDTP,4              IS IT PC                         05440000
         BE    RLPRT                   YES                              05450000
         MVC   PRT+70(2),=C'PR'        ASSUME PR                        05460000
         CLI   RLDESDTP,6              IS IT PR                         05470000
         BE    RLPRT                   YES                              05480000
         MVC   PRT+70(2),=C'CM'        ASSUME CM                        05490000
         CLI   RLDESDTP,5              IS IT CM                         05500000
         BE    RLPRT                   YES                              05510000
         MVC   PRT+70(2),=C'WX'        ASSUME WX                        05520000
         CLI   RLDESDTP,X'0A'          IS IT WX                         05530000
         BE    RLPRT                   YES                              05540000
         MVC   PRT+70(4),=C'NULL'      ASSUME NULL                      05550000
         CLI   RLDESDTP,7              IS IT NULL                       05560000
         BE    RLPRT                   YES                              05570000
         MVC   PRT+70(6),=C'E/STAB'    ASSUME E/STAB                    05580000
         CLI   RLDESDTP,X'0F'          IS IT E/STAB                     05590000
         BE    RLPRT                   YES                              05600000
         MVC   PRT+70(6),=C'??????'    UNKNOWN YPE                      05610000
RLPRT    DS    0H                                                       05620018
         BAL   R9,PRINT                PRINT                            05630018
         CLC   RLDNAME,CSECT           RLD NAME IS CSECT NAME           05640000
         BNE   GOODRLD                 NO                               05650000
         CLC   RLDADDR,XZROS           RELATIVE OFFSET IS ZERO          05660000
         BE    RLDSTEP                 YES, IGNORE ENTRY                05670000
GOODRLD  DS    0H                                                       05680018
         LA    R7,L'RLDENT(,R7)        TO NEXT TBL ENTRY                05690018
RLDSTEP  DS    0H                                                       05700018
         TM    0(R6),1                 NEXT ITEM HAS REL AND POS PTRS   05710018
         BO    RLSAME                  NO                               05720000
         LH    R10,4(,R6)              PICK UP NEW REL PTR              05730013
         LH    R11,6(,R6)              PICK UP NEW POS PTR              05740013
         LA    R6,4(,R6)               STEP OVER 4 BYTES                05750013
RLSAME   DS    0H                                                       05760018
         LA    R6,4(,R6)               TO NEXT RLD ITEM                 05770018
         CR    R6,R8                   END OF RLD DATA                  05780000
         BL    RLDNXT                  NO                               05790000
         MVI   0(R7),X'FF'             SET TBL END INDIC                05800000
         ST    R7,CURRLD               SET NEW CURRENT ADDRESS          05810000
         L     R9,RL9                  GET RETURN ADDR                  05820000
         BR    R9                      EXIT                             05830000
         DROP  R7                                                       05840000
****************************************************************        05850000
*                                                              *        05860000
* PROCESS CONTROL AND RLD RECORDS. THESE RECORDS CONTAIN BOTH  *        05870000
* RLD AND CONTROL INFORMATION, AND ARE PROCESSED BY BOTH       *        05880000
* THE RLDRECS AND CNTLRECS ROUTINES.                           *        05890000
*                                                              *        05900000
****************************************************************        05910000
CTRLRECS DS    0H                      CONTROL AND RLD RECORDS          05920013
         ST    R9,CR9                  SAVE RETURN ADDR                 05930000
         BAL   R9,RLDRECS              PROCESS RLD DATA                 05940000
         L     R6,BUFAD                RESET BUFFER ADDRESS             05950000
         BAL   R9,CNTLRECS             PROCESS CONTROL DATA             05960000
         L     R9,CR9                  GET RETURN ADDR                  05970000
         BR    R9                      EXIT                             05980000
****************************************************************        05990000
*                                                              *        06000000
* PROCESS COMPOSITE ESD RECORDS. DATA FROM THESE RECORDS IS    *        06010000
* PLACED IN THE SYMBOL TABLE, AND IS USED TO CREATE PROGRAM    *        06020000
* ENTRY STATEMENTS, AND TO IDENTIFY THE NAMES OF EXTERNAL      *        06030000
* SYMBOLS USED BY THE PROGRAM.                                 *        06040000
*                                                              *        06050000
****************************************************************        06060000
CESDREC  DS    0H                      CESD RECORD PROCESSING           06070013
         ST    R9,CES9                 SAVE RETURN                      06080000
         L     R7,CURRSYM              GET SYMBOL TBL ADDR              06090000
         USING SYMTBL,R7                                                06100000
         LH    R10,4(,R6)              GET ESD ID OF 1ST ITEM           06110013
         LH    R8,6(,R6)               NBR BYTES OF ESD DATA            06120013
         SRL   R8,4                    COMPUTE NBR ENTRIES              06130000
         LA    R6,8(,R6)               STEP TO 1ST RECORD ESD ITEM      06140013
CESDNXT  DS    0H                                                       06150018
         C     R7,ENDSYM               END OF TABLE                     06160018
         BNL   SYMFULL                 YES, ERROR                       06170000
         MVC   EXTSYM,0(R6)            SYMBOL NAME                      06180000
         MVC   TYPSYM,8(R6)            TYPE                             06190000
         NI    TYPSYM,X'0F'            CLEAR BITS 0-3                   06200000
         MVC   SYMIND,8(R6)            INDICATOR BYTE                   06210000
         NI    SYMIND,X'0F'            CLEAR BITS 4-7                   06220000
         TM    8(R6),X'14'             POSSIBLE ENTAB/SEGTAB            06230000
         BNO   CEMVAD                  NO                               06240000
         TM    8(R6),X'03'             IS IT ENTAB/SEGTAB               06250000
         BNZ   CEMVAD                  NO                               06260000
         MVC   TYPSYM(2),=X'0F00'      SHOW ENTAB/SEGTAB                06270000
CEMVAD   DS    0H                                                       06280018
         MVC   SYMADDR,9(R6)           ADDRESS OF SYMBOL                06290018
         MVC   SYMSEG,12(R6)           SEGMENT WHERE DEFINED            06300000
         MVC   SYMLENG,13(R6)          LENGTH OR LR ESD ID              06310000
         STCM  R10,3,SYMESDID          ESD ID                           06320000
         MVC   PRT+5(8),EXTSYM         SYMBOL NAME                      06330000
         OC    PRT+5(8),BLANX                                       DSK 06340010
         MVC   PRT+20(2),=C'SD'        ASSUME SD                        06350000
         CLI   TYPSYM,0                IS IT SD                         06360000
         BE    CEPIND                  YES                              06370000
         MVC   PRT+20(2),=C'LR'        ASSUME LR                        06380000
         CLI   TYPSYM,3                IS IT LR                         06390000
         BE    CEPIND                  YES                              06400000
         MVC   PRT+20(2),=C'ER'        ASSUME ER                        06410000
         CLI   TYPSYM,2                IS IT ER                         06420000
         BE    CEPIND                  YES                              06430000
         MVC   PRT+20(2),=C'PC'        ASSUME PC                        06440000
         CLI   TYPSYM,4                IS IT PC                         06450000
         BE    CEPIND                  YES                              06460000
         MVC   PRT+20(2),=C'PR'        ASSUME PR                        06470000
         CLI   TYPSYM,6                IS IT PR                         06480000
         BE    CEPIND                  YES                              06490000
         MVC   PRT+20(2),=C'CM'        ASSUME CM                        06500000
         CLI   TYPSYM,5                IS IT CM                         06510000
         BE    CEPIND                  YES                              06520000
         MVC   PRT+20(2),=C'WX'        ASSUME WX                        06530000
         CLI   TYPSYM,X'0A'            IS IT WX                         06540000
         BE    CEPIND                  YES                              06550000
         MVC   PRT+20(4),=C'NULL'      ASSUME NULL                      06560028
         CLI   TYPSYM,7                IS IT NULL                       06570000
         BE    CEPIND                  YES                              06580000
         MVC   PRT+20(6),=C'E/STAB'    ASSUME ENTAB/SEGTAB              06590028
         CLI   TYPSYM,X'0F'            IS IT ENTAB/SEGTAB               06600000
         BE    CEPIND                  YES                              06610000
         MVC   PRT+20(2),=C'?:'        UNIDENTIFIABLE TYPE              06620028
         LA    R12,TYPSYM              @ TYPE                           06630000
         BAL   R9,HEXPRT1              CONVERT                          06640000
         MVC   PRT+22(2),PRTABL        TYPE                             06650028
CEPIND   DS    0H                                                       06660018
         LA    R12,SYMIND              @ INDICATOR                      06670018
         BAL   R9,HEXPRT1              CONVERT                          06680000
         MVC   PRT+27(1),PRTABL        INDICATOR                        06690000
         LA    R12,SYMADDR             @ SYMBOL ADDR                    06700000
         BAL   R9,HEXPRT3              CONVERT                          06710000
         MVC   PRT+30(6),PRTABL        SYMBOL ADDR                      06720000
         LA    R12,SYMSEG              @ SEGMENT NBR                    06730000
         BAL   R9,HEXPRT1              CONVERT                          06740000
         MVC   PRT+39(2),PRTABL        SEGMENT NBR                      06750000
         CLI   TYPSYM,2                IS IT ER                         06760000
         BE    CEESD                   YES                              06770000
         CLI   TYPSYM,3                IS IT AN LR                      06780000
         BNE   CENOTLR                 NO                               06790000
         LA    R12,SYMLRID             @ LR ESD ID                      06800000
         BAL   R9,HEXPRT2              CONVERT                          06810000
         MVC   PRT+43(4),PRTABL        LR ESD ID                        06820000
         B     CEESD                   CONTINUE                         06830000
CENOTLR  DS    0H                                                       06840018
         LA    R12,SYMLENG             @ LENGTH                         06850018
         BAL   R9,HEXPRT3              CONVERT                          06860000
         MVC   PRT+49(6),PRTABL        SYMBOL LENGTH                    06870000
CEESD    DS    0H                                                       06880018
         LA    R12,SYMESDID            @ ESD ID                         06890018
         BAL   R9,HEXPRT2              CONVERT                          06900000
         MVC   PRT+57(4),PRTABL        ESD ID                           06910000
         TM    PROCESS,X'80'           FOUND CSECT                      06920000
         BO    CESDPT                  YES                              06930000
         CLI   TYPSYM,0                SD                               06940000
         BE    CECKCSB                 YES                              06950000
         CLI   TYPSYM,4                PC                               06960000
         BNE   CESDPT                  NO                               06970000
CECKCSB  DS    0H                                                       06980018
         CLC   CSECT,BLANX             ANY CSECT NAME ENTERED           06990018
         BNE   CECKNM                  YES                              07000000
         MVC   CSECT,EXTSYM            NAME TO CSECT                    07010000
         B     CSGOTCS                 CONTINUE                         07020000
CECKNM   DS    0H                                                       07030018
         CLI   TYPSYM,4                PC                               07040018
         BE    CESDPT                  YES                              07050000
         CLC   CSECT,EXTSYM            FOUND DESIRED NAME               07060000
         BNE   CESDPT                  NO                               07070000
         TM    PROCESS,X'80'           ALREADY FOUND CSECT              07080000
         BZ    CSGOTCS                 NO                               07090000
         MVC   PRT+15(2),=C'??'        SHOW DUPL                        07100000
         B     CESDPT                  CONTINUE                         07110000
CSGOTCS  DS    0H                                                       07120018
         OI    PROCESS,X'80'           SHOW CSECT FOUND                 07130018
         MVC   PRT+15(2),=C'**'        FLAG ON PRINTOUT                 07140000
         MVC   ESDID,SYMESDID          SAVE ESD ID FOUND                07150000
         MVC   START+1,SYMADDR         SAVE CSECT START ADDR            07160000
         MVC   LENGTH+1(3),SYMLENG     SAVE CSECT LENGTH                07170000
         L     R1,LENGTH               PICK UP LENGTH                   07180000
         A     R1,START                COMPUTE CSECT END ADDR           07190000
         BCTR  R1,0                                                     07200034
         ST    R1,END                  SAVE CSECT END ADDR              07210000
         L     R11,LENGTH              TEXT LENGTH                      07220000
         LA    R11,256(,R11)           ADD FOR SAFETY                   07230013
         GETMAIN R,LV=(11)             GET STORAGE FOR TEXT             07240000
         ST    R1,TXTSTRT              SAVE TEXT ADDR                   07250000
         SH    R11,=H'256'             DEDUCT SAFETY FACTOR             07260024
         AR    R1,R11                  TXT END ADDR                     07270000
         ST    R1,TXTEND               SAVE TEXT END ADDR               07280000
CESDPT   DS    0H                                                       07290018
         BAL   R9,PRINT                PRINT                            07300018
         LA    R7,L'SYMENT(,R7)        TO NEXT TBL ENTRY LOCATION       07310013
         LA    R10,1(,R10)             ADD 1 TO ESD COUNTER             07320013
         LA    R6,16(,R6)              TO NEXT ESD ITEM IN INPUT        07330013
         BCT   R8,CESDNXT              LOOP THRU INPUT RECORD           07340000
         MVI   0(R7),X'FF'             SET END OF TABLE INDIC           07350000
         ST    R7,CURRSYM              SAVE NEXT TABLE ADDR             07360000
         L     R9,CES9                 GET RETURN ADDR                  07370000
         BR    R9                      EXIT                             07380000
         DROP  R7                                                       07390000
****************************************************************        07400000
*                                                              *        07410000
* ISSUE BLDL FOR THE MAIN MODULE, AND PRINT MODULE RELATED INFO*        07420000
*                                                              *        07430000
****************************************************************        07440000
BLDL     DS    0H                      ISSUE BLDL AND PRINT INFO        07450013
         ST    R9,BL9                  SAVE RETURN ADDR                 07460000
ISSBLDL  DS    0H                                                       07470018
         BLDL  SYSLIB,BLDLIST          ISSUE BLDL                       07480018
         LTR   R15,R15                 ANY ERRORS                       07490000
         BNZ   MISSMEM                 YES                              07500000
         LA    R1,MEMBER+35            END OF BASIC PORTION             07510000
         TM    ATTR2,X'10'             SSI PRESENT                      07520000
         BZ    BLREFA1                 NO                               07530000
         LA    R1,4(,R1)               ADD FOR SSI                      07540013
BLREFA1  DS    0H                                                       07550018
         TM    ALIASIND,X'80'          ALIAS                            07560018
         BZ    BLREFA2                 NO                               07570000
         LA    R1,11(,R1)              ADD FOR ALIAS                    07580013
BLREFA2  DS    0H                                                       07590018
         TM    ATTR1A,X'04'            SCATTER FORMAT                   07600018
         BZ    BLREFA3                 NO                               07610000
         LA    R1,8(,R1)               ADD FOR SCATTER                  07620013
BLREFA3  DS    0H                                                       07630018
         MVC   AUTHLEN(2),0(R1)        AUTH LENGTH AND CODE             07640018
         TM    ATTR2,X'10'             SSI PRESENT                      07650000
         BZ    BLCKALI                 NO                               07660000
         LA    R1,MEMBER+35            END OF BASIC PORTION             07670000
         TM    ATTR1A,X'04'            SCATTER FORMAT                   07680000
         BZ    BLSSI2                  NO                               07690000
         TM    ALIASIND,X'80'          ALIAS                            07700000
         BO    BLFMTED                 YES, NO REFORMAT NEEDED          07710000
         LA    R1,8(,R1)               NO, STEP PAST SCATTER SECTION    07720013
         B     BLMVSSI                 GO MOVE SSI                      07730000
BLSSI2   DS    0H                                                       07740018
         TM    ALIASIND,X'80'          ALIAS                            07750018
         BZ    BLMVSSI                 NO                               07760000
         LA    R1,11(,R1)              YES, STEP PAST ALIAS SECTION     07770018
BLMVSSI  DS    0H                                                       07780018
         MVC   SSI,0(R1)               MOVE SSI DATA                    07790018
BLCKALI  DS    0H                                                       07800018
         TM    ALIASIND,X'80'          ALIAS                            07810018
         BO    BLASC                   YES                              07820000
         B     BLFMTED                 FINISHED                         07830000
BLASC    DS    0H                                                       07840018
         TM    ATTR1A,X'04'            SCATTER FORMAT                   07850018
         BO    BLFMTED                 YES, NO REFORMAT NEEDED          07860000
         MVC   ALMEM,MEMBER+38         MOVE ALIAS MEMBER                07870000
         MVC   ALEPA(3),MEMBER+35      YES, MOVE ALIAS DATA             07880000
BLFMTED  DS    0H                                                       07890018
         BAL   R9,PRINT                PRINT                            07900033
         MVC   PRT(26),=C'Directory info for module='                   07910027
         MVC   PRT+26(8),MEMBER        MEMBER NAME TO PRINT             07920015
         BAL   R9,PRINT                PRINT                            07930000
         MVC   PRT+10(14),=C'TTR of module='                            07940027
         LA    R12,TTRMOD              @ TTR                            07950000
         BAL   R9,HEXPRT3              CONVERT                          07960000
         MVC   PRT+24(6),PRTABL        TTR TO PRINT                     07970000
         BAL   R9,PRINT                PRINT                            07980000
         MVC   PRT+10(21),=C'Concatenation number='                     07990027
         LA    R12,CCAT                @ CONCATENATION NBR              08000000
         BAL   R9,HEXPRT1              CONVERT                          08010000
         MVC   PRT+31(2),PRTABL        CONCATENATION NBR                08020027
         BAL   R9,PRINT                PRINT                            08030000
         MVC   PRT+10(16),=C'Alias indicator='                          08040027
         LA    R12,ALIASIND            @ ALIAS INDICATOR                08050000
         BAL   R9,HEXPRT1              CONVERT                          08060000
         MVC   PRT+26(2),PRTABL        ALIAS INDICATOR                  08070027
         TM    ALIASIND,X'80'          IS IT AN ALIAS                   08080000
         BZ    BLALPRT                 NO                               08090000
         MVC   PRT+50(13),=C'*** Alias ***'                             08100027
BLALPRT  DS    0H                                                       08110018
         BAL   R9,PRINT                PRINT                            08120018
         MVC   PRT+10(22),=C'TTR of 1st TXT record='                    08130028
         LA    R12,TTR1TXT             @ TTR                            08140000
         BAL   R9,HEXPRT3              CONVERT                          08150000
         MVC   PRT+32(6),PRTABL        TTR OF 1ST TXT BLOCK             08160028
         BAL   R9,PRINT                PRINT                            08170000
         MVC   PRT+10(25),=C'TTR of NOTE/SCATTER list='                 08180027
         LA    R12,TTRNS               @ TTR                            08190000
         BAL   R9,HEXPRT3              CONVERT                          08200000
         MVC   PRT+35(6),PRTABL        TTR OF NOTE/SCATTER              08210000
         BAL   R9,PRINT                PRINT                            08220000
         MVC   PRT+10(20),=C'Number NOTE entries='                      08230027
         LA    R12,NNOTE               @ NBR NOTES                      08240000
         BAL   R9,HEXPRT1              CONVERT                          08250000
         MVC   PRT+30(2),PRTABL        NBR NOTE ENTRIES                 08260027
         BAL   R9,PRINT                PRINT                            08270000
         MVC   PRT+10(18),=C'Attributes byte 1='                        08280027
         LA    R12,ATTR1A              @ ATTRIBUTES                     08290000
         BAL   R9,HEXPRT2              CONVERT                          08300000
         MVC   PRT+28(4),PRTABL        ATTRIBUTES 1                     08310027
         LA    R1,PRT+33                                                08320027
         TM    ATTR1A,X'80'            RENT                             08330000
         BNO   BLAT1A                  NO                               08340028
         MVC   0(4,R1),=C'RENT'                                         08350027
         LA    R1,5(,R1)                                                08360027
BLAT1A   DS    0H                                                       08370018
         TM    ATTR1A,X'40'            REUS                             08380018
         BNO   BLAT1B                  NO                               08390028
         MVC   0(4,R1),=C'REUS'                                         08400027
         LA    R1,5(,R1)                                                08410027
BLAT1B   DS    0H                                                       08420018
         TM    ATTR1A,X'20'            OVLY                             08430018
         BNO   BLAT1C                  NO                               08440028
         MVC   0(4,R1),=C'OVLY'                                         08450027
         LA    R1,5(,R1)                                                08460027
BLAT1C   DS    0H                                                       08470018
         TM    ATTR1A,X'10'            TEST                             08480018
         BNO   BLAT1D                  NO                               08490028
         MVC   0(4,R1),=C'TEST'                                         08500027
         LA    R1,5(,R1)                                                08510027
BLAT1D   DS    0H                                                       08520018
         TM    ATTR1A,X'08'            OL                               08530028
         BNO   BLAT1E                  NO                               08540028
         MVC   0(2,R1),=C'OL'                                           08550027
         LA    R1,3(,R1)                                                08560027
BLAT1E   DS    0H                                                       08570018
         TM    ATTR1A,X'04'            SCTR                             08580018
         BNO   BLAT1F                  NO                               08590028
         MVC   0(4,R1),=C'SCTR'                                         08600027
         LA    R1,5(,R1)                                                08610027
BLAT1F   DS    0H                                                       08620018
         TM    ATTR1A,X'02'            EXEC                             08630018
         BNO   BLAT1G                  NO                               08640028
         MVC   0(4,R1),=C'EXEC'                                         08650027
         LA    R1,5(,R1)                                                08660027
BLAT1G   DS    0H                                                       08670018
         TM    ATTR1B,X'01'            REFR                             08680018
         BNO   BLAT1PRT                NO                               08690028
         MVC   0(4,R1),=C'REFR'                                         08700027
         LA    R1,5(,R1)                                                08710027
BLAT1PRT DS    0H                                                       08720018
         BAL   R9,PRINT                PRINT                            08730018
         MVC   PRT+10(13),=C'Total length='                             08740027
         LA    R12,TOTVIRT             @ TOTAL LENGTH                   08750000
         BAL   R9,HEXPRT3              CONVERT                          08760000
         MVC   PRT+23(6),PRTABL        TOTAL LENGTH OF MODULE           08770000
         BAL   R9,PRINT                PRINT                            08780000
         MVC   PRT+10(25),=C'Length of 1ST TXT record='                 08790027
         LA    R12,LENG1               @ 1ST TXT LENG                   08800000
         BAL   R9,HEXPRT2              CONVERT                          08810000
         MVC   PRT+35(4),PRTABL        LENGTH OF 1ST TXT BLOCK          08820027
         BAL   R9,PRINT                PRINT                            08830000
         MVC   PRT+10(20),=C'Entry Point address='                      08840027
         LA    R12,LKEPA               @ E.P. ADDR                      08850000
         BAL   R9,HEXPRT3              CONVERT                          08860000
         MVC   PRT+30(6),PRTABL        E.P. ADDR                        08870027
         BAL   R9,PRINT                PRINT                            08880000
         MVC   PRT+10(18),=C'Attributes byte 2='                        08890027
         LA    R12,ATTR2               @ ATTRIBUTES 2                   08900000
         BAL   R9,HEXPRT1              CONVERT                          08910000
         MVC   PRT+28(2),PRTABL        ATTRIBUTES 2                     08920027
         LA    R1,PRT+31                                                08930028
         TM    ATTR2,X'20'             PAGE ALIGNMENT                   08940000
         BZ    BLAT3A                  NO                               08950000
         MVC   0(10,R1),=C'Page align'                                  08960027
         LA    R1,11(,R1)                                               08970027
BLAT3A   DS    0H                                                       08980018
         TM    ATTR2,X'10'             SSI PRESENT                      08990018
         BZ    BLAT3PRT                NO                               09000000
         MVC   0(11,R1),=C'SSI present'                                 09010027
         LA    R1,12(,R1)                                               09020027
BLAT3PRT DS    0H                                                       09030018
         BAL   R9,PRINT                PRINT                            09040018
         TM    ATTR1A,X'04'            SCATTER FORMAT                   09050000
         BZ    BLFAL                   NO                               09060000
         MVC   PRT+10(12),=C'SCTR Length='                              09070027
         LA    R12,SCTRLEN             @ SCATTER LIST LENGTH            09080000
         BAL   R9,HEXPRT2              CONVERT                          09090000
         MVC   PRT+22(4),PRTABL        SCATTER LIST LENGTH              09100027
         BAL   R9,PRINT                PRINT                            09110000
         MVC   PRT+10(23),=C'Translate table length='                   09120027
         LA    R12,TTLEN               @ TRANS TBL LEN                  09130000
         BAL   R9,HEXPRT2              CONVERT                          09140000
         MVC   PRT+33(4),PRTABL        TRANSLATION TABLE LENGTH         09150027
         BAL   R9,PRINT                PRINT                            09160000
         MVC   PRT+10(18),=C'ESD id of 1st TXT='                        09170027
         LA    R12,SCESDID             @ ESD ID                         09180000
         BAL   R9,HEXPRT2              CONVERT                          09190000
         MVC   PRT+28(4),PRTABL        ESD ID OF 1ST TXT                09200000
         BAL   R9,PRINT                PRINT                            09210000
         MVC   PRT+10(22),=C'ESD id containing EPA='                    09220027
         LA    R12,SCEPESD             @ ESD ID                         09230000
         BAL   R9,HEXPRT2              CONVERT                          09240000
         MVC   PRT+32(4),PRTABL        @ ESD ID OF CSECT CONTAINING E.P 09250027
         BAL   R9,PRINT                PRINT                            09260000
BLFAL    DS    0H                                                       09270018
         TM    ALIASIND,X'80'          ALIAS                            09280018
         BZ    BLFSSI                  NO                               09290000
         MVC   PRT+10(27),=C'EPA address of this member='               09300027
         LA    R12,ALEPA               @ E.P. ADDR                      09310000
         BAL   R9,HEXPRT3              CONVERT                          09320000
         MVC   PRT+37(6),PRTABL        E.P. ADDR                        09330027
         BAL   R9,PRINT                                                 09340000
         MVC   PRT+10(17),=C'Real member name='                         09350027
         MVC   PRT+27(8),ALMEM         REAL MEMBER NAME                 09360000
         BAL   R9,PRINT                                                 09370000
BLFSSI   DS    0H                                                       09380018
         TM    ATTR2,X'10'             ANY SSI INFO                     09390018
         BZ    BLAUTHC                 NO                               09400000
         MVC   PRT+10(9),=C'SSI info='                                  09410027
         LA    R12,SSI                 @ SSI INFO                       09420000
         BAL   R9,HEXPRT4              CONVERT                          09430000
         MVC   PRT+19(8),PRTABL        SSI INFO                         09440000
         BAL   R9,PRINT                PRINT                            09450000
BLAUTHC  DS    0H                                                       09460018
         MVC   PRT+10(10),=C'Auth code='                                09470027
         LA    R12,AUTHCOD             @ AUTH CODE                      09480000
         BAL   R9,HEXPRT1              CONVERT                          09490000
         MVC   PRT+20(2),PRTABL        AUTH CODE                        09500000
         BAL   R9,PRINT                PRINT                            09510000
         TM    ALIASIND,X'80'          ALIAS                            09520000
         BZ    BLXIT                   NO                               09530000
         MVC   PRT+5(38),=C'***** Real member directory info *****'     09540027
         MVI   PCC,C'0'                DOUBLE SPACE                     09550000
         BAL   R9,PRINT                PRINT                            09560000
         MVC   MEMBER,ALMEM            REAL MEMBER NAME TO LIST         09570000
         B     ISSBLDL                 DO OVER FOR REAL MEMBER          09580000
BLXIT    DS    0H                                                       09590018
         L     R9,BL9                  GET RETURN ADDR                  09600018
         BR    R9                      EXIT                             09610000
****************************************************************        09620000
*                                                              *        09630000
* CREATE PRINTABLE HEX FROM HEX. ON ENTRY, REG 12 CONTAINS THE *        09640000
* ADDRESS OF THE DATA TO BE REFORMATTED. ENTRY POINT USED      *        09650000
* DETERMINES THE SIZE OF THE FIELD. OUTPUT DATA IS PLACED IN   *        09660000
* THE PRTABL FIELD, 2 CHARACTERS PER BYTE.                     *        09670000
*                                                              *        09680000
****************************************************************        09690000
HEXPRT   DS    0H                      HEX TO PRINTABLE ROUTINE         09700027
HEXPRT1  DS    0H                                                       09710018
         UNPK  PRTABL(3),0(2,R12)      UNPACK HEX                       09720018
         B     HEXCLTR                 CONTINUE                         09730000
HEXPRT2  DS    0H                                                       09740018
         UNPK  PRTABL(5),0(3,R12)      UNPACK HEX                       09750018
         B     HEXCLTR                 CONTINUE                         09760000
HEXPRT3  DS    0H                                                       09770018
         UNPK  PRTABL(7),0(4,R12)      UNPACK HEX                       09780018
         B     HEXCLTR                 CONTINUE                         09790000
HEXPRT4  DS    0H                                                       09800018
         UNPK  PRTABL(9),0(5,R12)      UNPACK HEX                       09810018
HEXCLTR  DS    0H                                                       09820018
         MVZ   PRTABL(8),XZROS         CLEAR FOR TRANSLATE              09830018
         TR    PRTABL(8),TRTBL         MAKE PRINTABLE                   09840000
         BR    R9                      EXIT                             09850000
****************************************************************        09860000
*                                                              *        09870000
* PRINT USING SYSPRINT.                                        *        09880000
*                                                              *        09890000
****************************************************************        09900000
PRINT    DS    0H                      PRINT ROUTINE                    09910013
         TM    SYSPRINT+48,X'10'       IS SYSPRINT OPEN                 09920000
         BNO   CLRPRT                  NO                               09930000
         PUT   SYSPRINT,PRTLINE        WRITE PRINT LINE                 09940000
CLRPRT   DS    0H                                                       09950018
         MVC   PRT,BLANX               CLEAR PRINT LINE                 09960018
         AP    LINECT,=P'1'            INCR LINE COUNTER                09970024
         CLI   PCC,C' '                SINGLE SPACED                    09980000
         BE    SETSGL                  YES                              09990000
         AP    LINECT,=P'1'            INCR LINE COUNTER                10000024
         CLI   PCC,C'0'                DOUBLE SPACED                    10010000
         BE    SETSGL                  YES                              10020000
         AP    LINECT,=P'1'            INCR LINE COUNTER                10030024
         CLI   PCC,C'-'                TRIPLE SPACED                    10040000
         BE    SETSGL                  YES                              10050000
         ZAP   LINECT,=P'0'            NO, MUST BE NEW PAGE             10060024
SETSGL   DS    0H                                                       10070018
         MVI   PCC,C' '                SET SINGLE SPACING               10080018
         CP    LINECT,=P'58'           PAST END OF PAGE                 10090024
         BH    NEWPAGE                 YES                              10100000
         BR    R9                      EXIT                             10110000
NEWPAGE  DS    0H                                                       10120018
         MVI   PCC,C'1'                SET SKIP TO HOF                  10130018
         ZAP   LINECT,=P'0'            RESET LINE COUNTER               10140024
         BR    R9                      EXIT                             10150000
****************************************************************        10160000
*                                                              *        10170000
* PROCESS THE CONTROL CARD CONTAINING MODULE NAME AND CSECT.   *        10180000
* THIS MUST BE THE FIRST CARD IN THE SYSIN DECK.               *        10190000
*                                                              *        10200000
****************************************************************        10210000
GETCTL   DS    0H                      EXTRACT DESIRED MEMBER/CSECT     10220013
         GET   SYSIN                   READ THE CONTROL CARD            10230000
         MVC   CTLSTMT,0(R1)           Save CSECT control statement     10240030
         LA    R12,72                  LENGTH OF CONTROL CARD           10250000
         LA    R11,8                   MAX LENGTH OF MEMBER NAME        10260000
         LA    R10,MEMBER              @ MEMBER NAME FIELD              10270000
CKBLK1   DS    0H                                                       10280018
         CLI   0(R1),C' '              CONTROL BYTE IS BLANK            10290018
         BNE   GCMEMOV                 NO, GO MOVE MEMBER NAME          10300000
         LA    R1,0(,R1)               TO NEXT CONTROL BYTE             10310013
         BCT   R12,CKBLK1              SUBTRACT 1 FROM REMAINING LENGTH 10320000
         B     GCEND                   ALL BLANKS, EXIT                 10330000
GCMEMOV  DS    0H                                                       10340018
         MVC   0(1,R10),0(R1)          CONTROL BYTE TO MEMBER NAME      10350018
         LA    R1,1(,R1)               TO NEXT CONTROL BYTE             10360013
         BCTR  R12,R0                  SUBTRACT 1 FROM LENGTH           10370000
         LA    R10,1(,R10)             TO NEXT NAME BYTE                10380013
         BCTR  R11,R0                  SUBTRACT 1 FROM LENGTH           10390000
         CLI   0(R1),C' '              GOT A BLANK                      10400000
         BE    GCSETUP2                YES                              10410000
         CLI   0(R1),C','              GOT A COMMA                      10420000
         BE    GCSETUP2                YES                              10430000
         LTR   R12,R12                 END OF CONTROL DATA              10440000
         BE    GCEND                   YES                              10450000
         LTR   R11,R11                 NAME FULL                        10460000
         BNZ   GCMEMOV                 NO, CONTINUE                     10470000
         B     NAMEOV8                 YES, NAME TOO LONG               10480000
GCSETUP2 DS    0H                                                       10490018
         LA    R11,8                   CSECT NAME MAX LENGTH            10500018
         LA    R10,CSECT               @ CSECT NAME FIELD               10510000
GCSTEP2  DS    0H                                                       10520018
         LA    R1,1(,R1)               STEP PAST BLANK                  10530018
         BCT   R12,GCHKBK2             CHECK NEXT FOR BLANK             10540000
         B     GCEND                   END OF SCAN                      10550000
GCHKBK2  DS    0H                                                       10560018
         CLI   0(R1),C' '              CONTROL DATA IS BLANK            10570018
         BE    GCSTEP2                 YES                              10580000
GCCSMOV  DS    0H                                                       10590018
         MVC   0(1,R10),0(R1)          CONTROL BYTE TO CSECT NAME       10600018
         LA    R1,1(,R1)               TO NEXT CONTROL BYTE             10610013
         LA    R10,1(,R10)             TO NEXT NAME BYTE                10620013
         BCTR  R12,R0                  DEDUCT 1 FROM CONTROL LENGTH     10630000
         BCTR  R11,R0                  DEDUCT 1 FROM NAME LENGTH        10640000
         LTR   R12,R12                 ANY CONTROL BYTES LEFT           10650000
         BZ    GCEND                   NO                               10660000
         CLI   0(R1),C' '              NEXT CONTROL BYTE BLANK          10670000
         BE    GCEND                   YES                              10680000
         LTR   R11,R11                 ANY NAME BYTES LEFT              10690000
         BNZ   GCCSMOV                 YES, LOOP                        10700000
         B     NAMEOV8                 NAME TOO LONG, ERROR             10710000
GCEND    DS    0H                                                       10720018
         CLC   MEMBER,BLANX            ANY MEMBER NAME FOUND            10730018
         BE    NOMBR                   NO                               10740000
         BR    R9                      EXIT                             10750000
****************************************************************        10760000
*                                                              *        10770000
* MISCELLANEOUS ERROR MESSAGES.                                *        10780000
*                                                              *        10790000
****************************************************************        10800000
ERRORS   DS    0H                      ERROR END MESSAGES               10810013
NOCTL    DS    0H                                                       10820018
         MVC   PRT(L'NOCNTRL),NOCNTRL  NO CONTROL INFO MESSAGE          10830018
         B     ERREND                  GO PRINT                         10840000
NOLIB    DS    0H                                                       10850018
         MVC   PRT(27),=C'SYSLIB DD statement missing'              DSK 10860027
         B     ERREND                  GO PRINT                     DSK 10870010
NAMEOV8  DS    0H                                                       10880018
         MVC   PRT(L'OVER8),OVER8      NAME OVER 8 MESSAGE              10890018
         B     ERREND                  GO PRINT                         10900000
NOMBR    DS    0H                                                       10910018
         MVC   PRT(L'NOMEM),NOMEM      MISSING MEMBER NAME MESSAGE      10920018
         B     ERREND                  GO PRINT                         10930000
MISSMEM  DS    0H                                                       10940018
         MVC   PRT(L'INVMEM),INVMEM    MEMBER NOT IN PDS MESSAGE        10950018
         MVC   PRT+L'INVMEM+2(8),MEMBER                            DSK  10960008
         B     ERREND                  GO PRINT                         10970000
MISSCS   DS    0H                                                       10980018
         MVC   PRT(L'INVCSECT),INVCSECT CSECT NOT IN MEMBER MESSAGE     10990018
         MVC   PRT+L'INVCSECT+2(8),MEMBER                          DSK  11000008
         MVC   PRT+L'INVCSECT+12(8),CSECT                          DSK  11010008
         B     ERREND                  GO PRINT                         11020000
SYMFULL  DS    0H                                                       11030018
         MVC   PRT(L'FULLSYM),FULLSYM  FULL SYM TBL MSG                 11040018
         B     ERREND                  GO PRINT                         11050000
RLDFULL  DS    0H                                                       11060018
         MVC   PRT(L'FULLRLD),FULLRLD  RLD TBL FULL MSDG                11070018
         B     ERREND                  GO PRINT                         11080000
ERREND   DS    0H                                                       11090018
         BAL   R9,PRINT                GO PRINT MESSAGE                 11100018
         B     TERMINAT                STOP RUN                     DSK 11110008
****************************************************************        11120000
*                                                              *        11130000
* COUNT THE ENTRIES IN THE ESD TABLE WHICH WILL RESULT IN      *        11140000
* ENTRIES IN THE LABEL TABLE.                                  *        11150000
*                                                              *        11160000
****************************************************************        11170000
ENDINIT  DS    0H                      *** FINAL PROCESSING ***         11180013
         L     R6,SYMTBAD              GET @ ESD TABLE                  11190000
         USING SYMTBL,R6                                                11200000
         LA    R7,4                    INITIAL LABEL COUNT VALUE        11210000
         TM    PRMOPT,DBGLABEL         Label debug                      11220034
         BNO   SYMCNT                  No                               11230034
         MVC   PRT+01(6),=C'Start='                                     11240034
         UNPK  PRT+07(7),START+1(4)                                     11250034
         TR    PRT+07(6),TRTBL-240                                      11260034
         MVC   PRT+13(5),=C' End='                                      11270034
         UNPK  PRT+18(7),END+1(4)                                       11280034
         TR    PRT+18(6),TRTBL-240                                      11290034
         MVI   PRT+24,C' '                                              11300034
         BAL   R9,PRINT                                                 11310034
SYMCNT   DS    0H                                                       11320018
         CLI   0(R6),X'FF'             END OF ESD TBL                   11330018
         BE    RLDCNT                  YES                              11340000
         TM    PRMOPT,DBGLABEL         Label debug                      11350035
         BNO   SYMCNT1                 No                               11360035
         MVI   PRT,C'-'                                                 11370035
         MVC   PRT+01(8),EXTSYM        EXTERNAL SYMBOL NAME             11380035
         MVC   PRT+10(4),=C'TYP='                                       11390035
         UNPK  PRT+14(3),TYPSYM(2)     SYMBOL TYPE                      11400035
         TR    PRT+14(2),TRTBL-240                                      11410035
         MVC   PRT+16(5),=C' IND='                                      11420035
         UNPK  PRT+21(3),SYMIND(2)     INDICATOR                        11430035
         TR    PRT+21(2),TRTBL-240                                      11440035
         MVC   PRT+23(5),=C' ADR='                                      11450035
         UNPK  PRT+28(7),SYMADDR(4)    SYMBOL ADDRESS                   11460035
         TR    PRT+28(6),TRTBL-240                                      11470035
         MVC   PRT+34(5),=C' SEG='                                      11480035
         UNPK  PRT+39(3),SYMSEG(2)     SEGMENT ID                       11490035
         TR    PRT+39(2),TRTBL-240                                      11500035
         MVC   PRT+41(5),=C' LEN='                                      11510035
         UNPK  PRT+46(7),SYMLENG(4)    LENGTH                           11520035
         TR    PRT+46(6),TRTBL-240                                      11530035
         MVC   PRT+52(5),=C' ESD='                                      11540035
         UNPK  PRT+57(7),SYMADDR(4)    ESD ID                           11550035
         TR    PRT+57(6),TRTBL-240                                      11560035
         MVI   PRT+63,C' '                                              11570035
SYMCNT1  DS    0H                                                       11580035
         CLI   TYPSYM,3                IS ESD AN LR ENTRY               11590000
         BNE   SCSTP                   NO, IGNORE                       11600000
         CLC   SYMADDR,START+1         ADDR BELOW DESIRED CSECT         11610000
         BL    SCSTP                   YES, IGNORE                      11620000
         CLC   SYMADDR,END+1           ADDR ABOVE DESIRED CSECT         11630034
         BH    SCSTP                   YES, IGNORE                      11640034
         TM    PRMOPT,DBGLABEL         Label debug                      11650035
         BNO   SYMCNT2                 No                               11660035
         MVI   PRT,C'+'                                                 11670035
SYMCNT2  DS    0H                                                       11680035
         LA    R7,1(,R7)               ADD TO LABEL COUNT               11690013
         MVC   SYMLENG,=C'***'         FLAG AS USABLE                   11700000
SCSTP    DS    0H                                                       11710018
         TM    PRMOPT,DBGLABEL         Label debug                      11720035
         BNO   SYMCNT3                 No                               11730035
         BAL   R9,PRINT                                                 11740035
SYMCNT3  DS    0H                                                       11750035
         LA    R6,L'SYMENT(,R6)        TO NEXT ESD ENTRY                11760018
         B     SYMCNT                                                   11770000
         DROP  R6                                                       11780000
****************************************************************        11790000
*                                                              *        11800000
* COUNT THE ENTRIES IN THE RLD TABLE WHICH WILL RESULT IN      *        11810000
* ENTRIES IN THE LABEL TABLE.                                  *        11820000
*                                                              *        11830000
****************************************************************        11840000
RLDCNT   DS    0H                                                       11850018
         L     R6,RLDTBL               GET RLD TBL ADDR                 11860018
         USING RLDTBLD,R6                                               11870000
RLDCEND  DS    0H                                                       11880018
         CLI   0(R6),X'FF'             END OF RLD TABLE                 11890018
         BE    LBLGET                  YES                              11900000
         CLC   RLDRP,ESDID             ESDID SAME AS DESIRED CSECT      11910000
         BNE   RLDC1                   NO, EXTRN REF                    11920000
         LA    R7,1(,R7)               ADD 1 TO LABEL COUNT             11930013
RLDC1    DS    0H                                                       11940018
         LA    R7,1(,R7)               ADD 1 TO LABEL COUNT             11950018
         LA    R6,L'RLDENT(,R6)        TO NEXT RLD ENTRY                11960013
         B     RLDCEND                 LOOP THRU RLD TBL                11970000
         DROP  R6                                                       11980000
LBLGET   DS    0H                                                       11990018
         MH    R7,LBLLGTH              COMPUTE LABEL TABLE SIZE         12000018
         L     R1,LENGTH               GET CSECT LENGTH                 12010000
         SRL   R1,2                    DIVIDE BY 4                      12020000
         MH    R1,LBLLGTH              TIMES LABEL ENTRY LENGTH         12030000
         AR    R7,R1                   TOTAL LABEL TABLE LENGTH         12040000
****************************************************************        12050000
*                                                              *        12060000
* CREATE INITIAL ENTRIES IN THE LABEL TABLE USING DATA FROM    *        12070000
* THE ESD AND RLD TABLES.                                      *        12080000
*                                                              *        12090000
****************************************************************        12100000
         GETMAIN R,LV=(7)              GET LABEL TBL STORAGE            12110000
         ST    R1,LBLTBL               SAVE LABEL TBL ADDR              12120000
         ST    R1,CURRLBL              SAVE CURRENT LABEL ADDR          12130000
         AR    R1,R7                   COMPUTE LABEL TBL END ADDR       12140000
         ST    R1,ENDLBL               SAVE END OF LBL TBL ADDR         12150000
         L     R6,LBLTBL               GET @ LABEL TABLE                12160000
         USING LABELD,R6                                                12170000
         L     R7,SYMTBAD              GET ESD TBL ADDR                 12180000
         USING SYMTBL,R7                                                12190000
         CLC   LKEPA,XZROS             E.P. ADDR ZERO                   12200000
         BE    LRENTS                  YES                              12210000
         SR    R1,R1                   CLEAR WORK                       12220000
         ICM   R1,7,LKEPA              PICK UP E.P. ADDR                12230000
         S     R1,START                RELATIVIZE IN CSECT              12240000
         BM    LRENTS                  NEG, ERROR                       12250000
         STCM  R1,7,LBLADR             SAVE OFFSET                      12260000
         MVI   LBLTYP,LBLTYPL          SET LABEL TYPE IN ENTRY          12270020
         LA    R12,LBLADR              POINT TO OFFSET                  12280000
         BAL   R9,HEXPRT3              CONVERT TO PRINTABLE             12290000
         MVI   LBLNAME,C'A'            1ST CHAR OF LABEL IS 'A'         12300000
         MVC   LBLNAME+1(6),PRTABL     END OF LABEL IS OFFSET           12310000
         LA    R6,L'LABEL(,R6)         TO NEXT LABEL ENTRY              12320013
         ST    R6,CURRLBL              SAVE IT'S ADDRESS                12330000
LRENTS   DS    0H                                                       12340018
         CLI   0(R7),X'FF'             END OF ESD TBL                   12350018
         BE    RLDLBLS                 YES                              12360000
         CLC   SYMLENG,=C'***'         THIS DESIRED LR ENTRY            12370000
         BE    GOTLR                   YES                              12380000
LRESTP   DS    0H                                                       12390018
         LA    R7,L'SYMENT(,R7)        TO NEXT ESD ENTRY                12400018
         B     LRENTS                  LOOP THRU ESD TBL                12410000
GOTLR    DS    0H                                                       12420018
         SR    R12,R12                 CLEAR WORK REG                   12430018
         ICM   R12,7,SYMADDR           GET SYMBOL ADDR                  12440000
         S     R12,START               RELATIVIZE IN CSECT              12450000
         STCM  R12,7,LBLADR            SAVE RELATIVE ADDR               12460000
         MVC   LBLNAME,EXTSYM          SYMBOL NAME TO OUTPUT            12470000
         MVI   LBLTYP,LBLTYPL          SHOW LABEL ENTRY                 12480020
         LA    R6,L'LABEL(,R6)         TO NEXT LABEL ENTRY              12490013
         ST    R6,CURRLBL              SAVE NEXT LABEL ENTRY ADDR       12500000
         B     LRESTP                  CONTINUE ESD PROCESSING          12510000
         DROP  R7                                                       12520000
RLDLBLS  DS    0H                                                       12530018
         L     R7,RLDTBL               GET RLD TBL ADDR                 12540018
         USING RLDTBLD,R7                                               12550000
RLDLBND  DS    0H                                                       12560018
         CLI   0(R7),X'FF'             END OF RLD TABLE                 12570018
         BE    PHASE1                  YES                              12580000
         CLC   RLDRP,ESDID             RLD ESDID = DESIRED CSECT ESDID  12590000
         BE    INTREFS                 YES, INTERNAL ADCON              12600000
         CLI   RLDTYPE,1               VCON                             12610000
         BE    EXTREFS                 YES                              12620000
         CLI   RLDTYPE,8               IS IT UNRESOLVED                 12630000
         BE    EXTREFS                 YES                              12640000
RLLSTP   DS    0H                                                       12650018
         LA    R7,L'RLDENT(,R7)        TO NEXT RLD ENTRY                12660018
         B     RLDLBND                 LOOP THRU RLD TABLE              12670000
EXTREFS  DS    0H                                                       12680018
         CLI   RLDESDTP,X'0A'          W-CON                            12690018
         BNE   VCONLBL                 NO, BUILD V-CON                  12700000
         MVI   LBLTYP,LBLTYPW          SHOW W-CON                       12710020
         B     FXTLBL                  CONTINUE LABEL ENTRY FORMAT      12720000
VCONLBL  DS    0H                                                       12730018
         MVI   LBLTYP,LBLTYPV          SHOW V-CON                       12740020
FXTLBL   DS    0H                                                       12750018
         MVC   LBLNAME,RLDNAME         NAME TO LABEL ENTRY              12760018
FINLBL   DS    0H                                                       12770018
         MVC   LBLADR,RLDADDR          ADDRESS TO LABEL ENTRY           12780018
         MVC   LBLLEN,RLDLEN           LENGTH TO LABEL ENTRY            12790000
         LA    R6,L'LABEL(,R6)         TO NEXT LABEL TBL ENTRY          12800013
         ST    R6,CURRLBL              SAVE CURRENT LABEL TBL ADDR      12810000
         B     RLLSTP                  CONTINUE LABEL TABLE BUILD       12820000
INTREFS  DS    0H                                                       12830018
         CLI   RLDTYPE,0               A-CON                            12840018
         BNE   RLLSTP                  NO, IGNORE                       12850000
         MVI   LBLTYP,LBLTYPL          SHOW LABEL ENTRY TYPE            12860020
         SR    R12,R12                 CLEAR WORK REG                   12870000
         ICM   R12,7,RLDADDR           GET RLD ADDR                     12880000
         A     R12,TXTSTRT             FIND LOC IN TEXT                 12890000
         MVC   LBLADR,1(R12)           MOVE TO LABEL ENTRY              12900000
         CLI   RLDLEN,4                ADCON IS 4-BYTES                 12910000
         BE    INTGOTL                 YES                              12920000
         MVC   LBLADR,0(R12)           TEXT TO LABEL ENTRY              12930000
         CLI   RLDLEN,3                ADCON IS 3-BYTES                 12940000
         BE    INTGOTL                 YES                              12950000
         MVC   LBLADR+1(2),0(R12)      TEXT TO LABEL ENTRY              12960000
         MVI   LBLADR,0                CLEAR 1ST BYTE                   12970000
         CLI   RLDLEN,2                ADCON IS 2-BYTES                 12980000
         BE    INTGOTL                 YES                              12990000
         XC    LBLADR,LBLADR           CLEAR LABEL ENTRY ADDR           13000000
         MVC   LBLADR+2(1),0(R12)      TEXT TO LABEL ENTRY              13010000
INTGOTL  DS    0H                                                       13020018
         SR    R12,R12                 CLEAR WORK                       13030018
         ICM   R12,7,LBLADR            GET ADDRESS                      13040000
         S     R12,START               RELATIVIZE IN CSECT              13050000
         BM    RLLSTP                  NEGATIVE, IGNORE                 13060000
         STCM  R12,7,LBLADR            STORE RELATIVE ADDRESS           13070000
         LA    R12,LBLADR              POINT TO ADDRESS                 13080000
         BAL   R9,HEXPRT3              CONVERT TO PRINTABLE             13090000
         MVI   LBLNAME,C'A'            SET LABEL ENTRY TYPE             13100000
         MVC   LBLNAME+1(6),PRTABL     LOW ORDER NAME POSITIONS         13110000
         MVI   LBLNAME+7,C' '          CLEAR LAST NAME BYTE             13120000
         MVC   L'LABEL(L'LABEL,R6),0(R6) COPY THIS ENTRY TO NEXT        13130000
         MVI   LBLLEN,0                SET LENGTH = 0                   13140000
         LA    R6,L'LABEL(,R6)         STEP TO NEXT                     13150013
         MVI   LBLTYP,LBLTYPA          SHOW TYPE                        13160020
         B     FINLBL                  FINISH LABEL                     13170000
         DROP  R6                                                       13180000
         DROP  R7                                                       13190000
****************************************************************        13200000
*                                                              *        13210000
* LOAD AND EXECUTE PHASE 1: DISASM1                            *        13220000
*                                                              *        13230000
****************************************************************        13240000
PHASE1   DS    0H                                                       13250018
         MVC   0(3,R6),HIVAL           SET END OF LABEL TABLE  FIX***   13260018
         TM    LOADLIB+48,X'10'        LOADLIB DD CARD ENTERED          13270000
         BZ    NODCB1                  NO                               13280000
         LOAD  EP=UTL31P1,DCB=LOADLIB  LOAD PHASE1                      13290000
         B     EXEC1                   CONTINUE                         13300000
NODCB1   DS    0H                                                       13310018
         LOAD  EP=UTL31P1              LOAD PHASE1                      13320018
EXEC1    DS    0H                                                       13330018
         LR    R15,R0                  COPY E.P. ADDRESS                13340018
         LA    R0,CTLSTMT              Pass 1st ctl card for printing   13350030
         LA    R1,=A(COMMPARM)         @ PARAMETER LIST                 13360000
         BALR  R14,R15                 LINK TO PHASE1                   13370000
         DELETE EP=UTL31P1             DELETE AFTER USE                 13380000
         CLI   USERR,0                 ANY ERRORS                       13390000
         BE    ENDP1                   NO, CONTINUE                 DSK 13400008
TERMINAT DS    0H                                                       13410018
         MVC   PRT(37),=C'Disassembly  terminated due to errors'    DSK 13420027
         BAL   R9,PRINT                PRINT ERROR MESSAGE          DSK 13430008
         LA    R2,8                    SET RETURN CODE TO 8         DSK 13440008
         B     CLOSES                  YES, STOP THE RUN            DSK 13450008
****************************************************************        13460000
*                                                              *        13470000
* PRINT THE LABEL TABLE AFTER PHASE 1 COMPLETION.              *        13480000
*                                                              *        13490000
****************************************************************        13500000
ENDP1    DS    0H                                                   DSK 13510008
         BAL   R9,PRINT                PRINT IT                     DSK 13520010
         MVC   PRT(L'PH1LBL),PH1LBL    PHASE 1 LINE                 DSK 13530010
         BAL   R9,PRINT                PRINT IT                         13540000
         MVC   PRT(L'PH1HDR),PH1HDR    HEADER 2                     DSK 13550010
         BAL   R9,PRINT                PRINT IT                         13560000
         L     R6,LBLTBL               GET LABEL TABLE ADDR             13570000
         USING LABELD,R6                                                13580000
LPEND    DS    0H                                                       13590018
         C     R6,CURRLBL              END OF TABLE       FIX****       13600018
         BNL   FREESTRG                YES                FIX****       13610000
         LA    R12,LBLADR              @ LABEL ADDRESS                  13620000
         BAL   R9,HEXPRT3              CONVERT                          13630000
         MVC   PRT(6),PRTABL           ADDRESS TO PRINT                 13640000
         MVC   PRT+9(1),LBLTYP         TYPE TO PRINT                    13650000
         MVC   PRT+12(8),LBLNAME       SYMBOL TO PRINT                  13660000
         CLI   LBLLEN,0                ANY LENGTH                       13670000
         BE    LTPPRT                  NO                               13680000
         LA    R12,LBLLEN              GET @ LENGTH                     13690000
         BAL   R9,HEXPRT1              CONVERT                          13700000
         MVC   PRT+22(2),PRTABL        LENGTH TO PRINT                  13710000
LTPPRT   DS    0H                                                       13720018
         BAL   R9,PRINT                PRINT TBL ENTRY                  13730018
         LA    R6,L'LABEL(,R6)         TO NEXT ENTRY                    13740013
         B     LPEND                   LOOP THRU TABLE                  13750000
FREESTRG DS    0H                                                       13760018
         L     R12,RLDTBL              @ RLD TABLE                      13770018
         FREEMAIN R,A=(12),LV=60000    FREE RLD TABLE                   13780000
****************************************************************        13790000
*                                                              *        13800000
* PRINT THE TEXT FOR THE CSECT TO BE DISASSEMBLED.             *        13810000
*                                                              *        13820000
****************************************************************        13830000
         BAL   R9,PRINT                PRINT                        DSK 13840010
         MVC   PRT+36(19),=C'***** T E X T *****'                       13850033
         BAL   R9,PRINT                PRINT TEXT HEADER                13860000
         L     R11,TXTSTRT             GET TEXT START ADDRESS           13870000
PNEXLIN  DS    0H                                                       13880018
         LA    R10,2                   GROUPS PER LINE                  13890018
         LA    R12,POFSET+1            @ OFFSET                         13900000
         BAL   R9,HEXPRT3              CONVERT                          13910000
         MVC   PRT(6),PRTABL           OFFSET TO PRINT                  13920000
         MVC   PRT+85(32),0(R11)       TEXT TO PRINT                    13930000
         TR    PRT+85(32),PRTCHAR      TRANSLATE TO PRINTABLE           13940000
         LA    R8,PRT+9                @ 1ST PRINT WORD                 13950000
         LA    R7,4                    4 WORDS PER GROUP                13960000
PGRP     DS    0H                                                       13970018
         LA    R12,0(,R11)             @ TEXT WORD                      13980018
         BAL   R9,HEXPRT4              CONVERT                          13990000
         MVC   0(8,R8),PRTABL          TEXT TO PRINT WORD               14000000
         LA    R11,4(,R11)             TO NEXT TEXT WORD                14010013
         LA    R8,9(,R8)               TO NEXT PRINT LOC                14020013
         BCT   R7,PGRP                 DO 4 TIMES                       14030000
         LA    R8,2(,R8)               SPACE BETWEEN GROUPS             14040013
         LA    R7,4                    FOR 2ND GROUP                    14050000
         BCT   R10,PGRP                DO 4 MORE TIMES                  14060000
         BAL   R9,PRINT                PRINT THE LINE                   14070000
         L     R9,POFSET               GET OFFSET                       14080000
         LA    R9,32(,R9)              ADD 32 BYTES                     14090013
         ST    R9,POFSET               UPDATE OFFSET                    14100000
         C     R11,TXTEND              END OF TEXT                      14110000
         BL    PNEXLIN                 NO, CONTINUE                     14120000
         BAL   R9,PRINT                PRINT TEXT HEADER                14130033
         MVC   PRT+28(23),=C'***** Disassembly *****'                   14140033
         BAL   R9,PRINT                PRINT TEXT HEADER                14150033
         MVC   WORKREC,BLANX           CLEAR OUTPUT RECORD              14160000
         MVC   NAME,CSECT              CSECT NAME                       14170000
****************************************************************        14180000
*                                                              *        14190000
* CREATE THE INITIAL CSECT INSTRUCTION, AND ANY ENTRY STATE-   *        14200000
* MENTS WHICH MAY BE INDICATED BY ESD TABLE ENTRIES.           *        14210000
*                                                              *        14220000
****************************************************************        14230000
         MVC   MNEMONIC,=C'CSECT'      SET MNEMONIC                     14240000
         BAL   R9,WRTOUT               WRITE OUTPUT RECORD              14250000
         BAL   R9,PRINT                AND PRINT IT                     14260000
         L     R7,SYMTBAD              GET ESD TBL ADDR                 14270000
         USING SYMTBL,R7                                                14280000
LREFSS   DS    0H                                                       14290018
         CLI   0(R7),X'FF'             END OF ESD TBL                   14300018
         BE    CKLDLB                  YES                              14310000
         CLC   SYMLENG,=C'***'         THIS DESIRED LR ENTRY            14320000
         BE    MAKEXT                  YES                              14330000
ESDTSTP  DS    0H                                                       14340018
         LA    R7,L'SYMENT(,R7)        TO NEXT ESD ENTRY                14350018
         B     LREFSS                  LOOP THRU ESD TBL                14360000
MAKEXT   DS    0H                                                       14370018
         MVC   MNEMONIC,=C'ENTRY'      MNEMONIC IS ENTRY                14380018
         MVC   OPNDS(8),EXTSYM         SYMBOL TO OPERAND                14390000
         BAL   R9,WRTOUT               WRITE OUTPUT RECORD              14400000
         BAL   R9,PRINT                AND PRINT IT                     14410000
         B     ESDTSTP                 CONTINUE ESD PROCESSING          14420000
         DROP  R7                                                       14430000
         DROP  R6                                                       14440000
CKLDLB   DS    0H                                                       14450018
         L     R12,SYMTBAD             @ ESD SYMBOL TABLE               14460018
****************************************************************        14470000
*                                                              *        14480000
* LOAD AND EXECUTE PHASE 2: DISASM2                            *        14490000
*                                                              *        14500000
****************************************************************        14510000
         FREEMAIN R,A=(12),LV=95000    FREE SYMBOL TABLE                14520000
         TM    LOADLIB+48,X'10'        LOADLIB DD CARD SUPPLIED         14530000
         BZ    NODCB                   NO                               14540000
         LOAD  EP=UTL31P2,DCB=LOADLIB  LOAD DISASM2                     14550000
         B     EXEC2                   CONTINUE                         14560000
NODCB    DS    0H                                                       14570018
         LOAD  EP=UTL31P2              LOAD DISASM2                     14580018
EXEC2    DS    0H                                                       14590018
         LR    R15,R0                  COPY E.P. ADDRESS                14600018
         LA    R1,=A(COMMPARM)         GET PARAMETER ADDRESS            14610000
         BALR  R14,R15                 CALL DISASM2                     14620000
         DELETE EP=UTL31P2             DELETE AFTER USE                 14630000
         B     EOJ                     GO FINISH                        14640000
****************************************************************        14650000
*                                                              *        14660000
* WRITE OUTPUT TO SYSPUNCH.                                    *        14670000
*                                                              *        14680000
****************************************************************        14690000
WRTOUT   DS    0H                      WRITE OUTPUT RECORDS             14700013
         AP    CARDNO,=P'10'           INCREMENT CARD NO                14710000
         UNPK  SEQNBR,CARDNO           UNPACK INTO CARD                 14720000
         OI    SEQNBR+7,C'0'           CLEAR SIGN                       14730000
         MVC   PRT(80),WORKREC         SAVE IN PRINT                    14740012
         TM    SYSPUNCH+48,X'10'       IS FILE OPEN                     14750012
         BZ    CLRWKR                  NO                               14760012
         PUT   SYSPUNCH,WORKREC        WRITE SOURCE CARD                14770000
CLRWKR   DS    0H                                                       14780018
         MVC   WORKREC,BLANX           CLEAR OUTPUT RECORD              14790018
         BR    R9                      RETURN                           14800000
****************************************************************        14810000
*                                                              *        14820000
* END OF JOB. DISASSEMBLY COMPLETE.                            *        14830000
*                                                              *        14840000
****************************************************************        14850000
EOJ      DS    0H                      END OF JOB                       14860013
EOFSW    B     NOCTL                   RESET IF CTL CARD FOUND          14870000
         MVC   MNEMONIC,=CL5'YREGS'    SET MNEMONIC                 DSK 14880006
         BAL   R9,WRTOUT               WRITE RECORD                     14890000
         BAL   R9,PRINT                GO PRINT IT                      14900000
         L     R12,DTBSTRT             @ DSECT HEADER TBL               14910000
         USING DTBD,R12                                                 14920014
CENDSTB  DS    0H                                                       14930018
         CLI   DTBNAM,X'FF'            END OF TABLE                     14940018
         BE    ENDSTMT                 YES                              14950000
         MVC   NAME,DTBNAM             DSECT NAME TO RECORD             14960014
         MVC   MNEMONIC(5),=C'DSECT'   OPERATION IS DSECT               14970000
         BAL   R9,WRTOUT               WRITE DSECT HEADER               14980000
         BAL   R9,PRINT                AND PRINT IT                     14990000
         ICM   R11,7,DTBFLD@           GET FIELD TABLE ADDR             15000014
         USING DSECTD,R11                                               15010000
CENDFTB  DS    0H                                                       15020018
         CLI   0(R11),X'FF'            END OF FIELD TABLE               15030018
         BNE   DFMTFLD                 NO                               15040000
         LA    R12,L'DTB(,R12)         TO NEXT DSECT HEADER             15050014
         B     CENDSTB                 LOOP                             15060000
DFMTFLD  DS    0H                                                       15070018
         MVC   NAME,DSNAME             NAME TO RECORD                   15080018
         MVC   MNEMONIC(3),=C'EQU'     OPERATION IS EQU                 15090000
         MVC   OPNDS(8),DTBNAM         BASE NAME TO OPERAND             15100014
         DROP  R12                                                      15110014
         LA    R10,OPNDS+7             @ NAME RHE                       15120000
CFRHE    DS    0H                                                       15130018
         CLI   0(R10),C' '             AT RHE                           15140018
         BNE   CFPLUS                  YES                              15150000
         BCT   R10,CFRHE               BACK UP 1 AND LOOP               15160000
CFPLUS   DS    0H                                                       15170018
         LA    R10,1(,R10)             TO NEXT POS                      15180018
         MVI   0(R10),C'+'             DELIMITER                        15190000
         SR    R1,R1                   CLEAR WORK                       15200000
         ICM   R1,7,DSOFSET            GET OFFSET                       15210000
         CVD   R1,DBLWD                CONVERT                          15220000
         UNPK  DBLWD(4),DBLWD+4(4)     UNPACK                           15230000
         OI    DBLWD+3,C'0'            CLEAR SIGN                       15240000
         CH    R1,=H'1000'             OFFSET < 1000                    15250024
         BL    CFO100                  YES                              15260000
         MVC   1(4,R10),DBLWD          NO, MOVE 4-DIGIT OFFSET          15270000
         LA    R10,5(,R10)             TO NEXT POS                      15280013
         B     CFCMA                   CONTINUE                         15290000
CFO100   DS    0H                                                       15300018
         CH    R1,=H'100'              OFFSET < 100                     15310024
         BL    CFO10                   YES                              15320000
         MVC   1(3,R10),DBLWD+1        NO, MOVE 3-DIGIT OFFSET          15330000
         LA    R10,4(,R10)             TO NEXT POS                      15340013
         B     CFCMA                   CONTINUE                         15350000
CFO10    DS    0H                                                       15360018
         CH    R1,=H'10'               OFFSET < 10                      15370024
         BL    CFO1                    YES                              15380000
         MVC   1(2,R10),DBLWD+2        MOVE 2-DIGIT OFFSET              15390000
         LA    R10,3(,R10)             TO NEXT POS                      15400013
         B     CFCMA                   CONTINUE                         15410000
CFO1     DS    0H                                                       15420018
         LTR   R1,R1                   ANY OFFSET                       15430018
         BZ    CFCMA                   NO                               15440000
         MVC   1(1,R10),DBLWD+3        YES, MOVE 1-DIGIT OFFSET         15450000
         LA    R10,2(,R10)             TO NEXT POS                      15460013
CFCMA    DS    0H                                                       15470018
         MVI   0(R10),C','             DELIMITER                        15480018
         SR    R1,R1                   CLEAR WORK                       15490000
         IC    R1,DSLENG               PICK UP LENGTH                   15500000
         CVD   R1,DBLWD                CONVERT                          15510000
         UNPK  DBLWD(3),DBLWD+4(4)     UNPACK                           15520000
         OI    DBLWD+2,C'0'            CLEAR SIGN                       15530000
         CH    R1,=H'100'              LENGTH < 100                     15540024
         BL    CFL10                   YES                              15550000
         MVC   1(3,R10),DBLWD          NO, MOVE 3-DIGIT LENGTH          15560000
         B     CFWRT                   CONTINUE                         15570000
CFL10    DS    0H                                                       15580018
         CH    R1,=H'10'               LENGTH < 10                      15590024
         BL    CFL1                    YES                              15600000
         MVC   1(2,R10),DBLWD+1        NO, MOVE 2-DIGIT LENGTH          15610000
         B     CFWRT                   CONTINUE                         15620000
CFL1     DS    0H                                                       15630018
         MVC   1(1,R10),DBLWD+2        MOVE 1-DIGIT LENGTH              15640018
CFWRT    DS    0H                                                       15650018
         BAL   R9,WRTOUT               WRITE THE RECORD                 15660018
         BAL   R9,PRINT                PRINT THE RECORD                 15670000
         LA    R11,L'DSECT(,R11)       TO NEXT FIELD ENTRY              15680013
         B     CENDFTB                 LOOP                             15690000
ENDSTMT  DS    0H                                                       15700018
         MVC   MNEMONIC,=CL5'END'      MNEMONIC TO OUTPUT RECORD        15710018
         MVC   OPNDS(8),ENDLBLNM       POINT END STMT TO BEGIN LOC      15720000
         BAL   R9,WRTOUT               WRITE THE RECORD                 15730000
         BAL   R9,PRINT                GO PRINT IT                      15740000
*                                                                       15750013
         TM    PRMOPT,DBGLABEL         PRINT LABEL TABLE?           DSK 15760013
         BNO   PLTBEND                 NO, SKIP DUMP OF LABEL TABLE DSK 15770013
         BAL   R9,PRINT                PRINT IT                     DSK 15780013
         MVC   PRT(L'PH1LBL),PH1LBL    PHASE 2 LINE                 DSK 15790013
         MVI   PRT+12,C'2'                                          DSK 15800013
         BAL   R9,PRINT                PRINT IT                     DSK 15810013
         MVC   PRT(L'PH1HDR),PH1HDR    HEADER 2                     DSK 15820013
         BAL   R9,PRINT                PRINT IT                     DSK 15830013
         L     R6,LBLTBL               GET LABEL TABLE ADDR         DSK 15840013
         USING LABELD,R6                                            DSK 15850013
PLTB     DS    0H                                                   DSK 15860013
         C     R6,ENDLBL               END OF TABLE                 DSK 15870013
         BNL   PLTBDON                 YES                          DSK 15880013
         CLI   LBLNAME,C' '            LABEL NAME PRESENT?          DSK 15890013
         BNH   PLTBNXT                 NO, SKIP THIS ONE            DSK 15900013
         LA    R12,LBLADR              @ LABEL ADDRESS              DSK 15910013
         BAL   R9,HEXPRT3              CONVERT                      DSK 15920013
         MVC   PRT(6),PRTABL           ADDRESS TO PRINT             DSK 15930013
         MVC   PRT+9(1),LBLTYP         TYPE TO PRINT                DSK 15940013
         MVC   PRT+12(8),LBLNAME       SYMBOL TO PRINT              DSK 15950013
         LA    R12,LBLLEN              GET @ LENGTH                 DSK 15960013
         BAL   R9,HEXPRT1              CONVERT                      DSK 15970013
         MVC   PRT+22(2),PRTABL        LENGTH TO PRINT              DSK 15980013
         BAL   R9,PRINT                PRINT TBL ENTRY              DSK 15990013
PLTBNXT  DS    0H                                                   DSK 16000013
         LA    R6,L'LABEL(,R6)         TO NEXT ENTRY                DSK 16010013
         B     PLTB                    LOOP THRU TABLE              DSK 16020013
PLTBDON  DS    0H                                                   DSK 16030013
         BAL   R9,PRINT                PRINT IT                     DSK 16040013
PLTBEND  DS    0H                                                   DSK 16050013
         SR    R2,R2                   RETURN CODE 0                DSK 16060008
*                                                                       16070013
CLOSES   DS    0H                                                   DSK 16080008
         CLOSE (SYSLIB,,SYSPUNCH,,SYSPRINT,,SYSIN) CLOSE FILES      DSK 16090008
         L     R13,4(,R13)             GET POINTER TO CALLER'S SAVE ARE 16100013
         L     R14,12(,R13)            RESTORE CALLER'S REGS        DSK 16110008
         LR    R15,R2                  SET RETURN CODE              DSK 16120008
         LM    R0,R12,12(R13)          RESTORE CALLER'S REGS        DSK 16130008
         BR    R14                     RETURN TO CALLER                 16140000
         DROP  R11                                                      16150000
****************************************************************        16160013
*                                                              *        16170014
*                 *** DATA AND WORK AREAS ***                  *        16180014
*                                                              *        16190014
****************************************************************        16200013
         LTORG ,                                                        16210024
BUFAD    DC    F'0'                    SYSLIB BUFFER ADDR               16220013
SYMTBAD  DC    F'0'                    SYMBOL TABLE ADDRESS             16230013
CURRSYM  DC    F'0'                    CURRENT SYM TBL ADDR             16240013
ENDSYM   DC    F'95000'                SYM TBL END ADDR                 16250013
RLDTBL   DC    F'0'                    ADDR OF RLD TABLE                16260013
CURRLD   DC    F'0'                    CURR RLD TBL ADDR                16270013
ENDRLD   DC    F'60000'                RLD TBL END ADDR                 16280013
CES9     DC    F'0'                    CESDREC RETURN ADDR              16290013
BL9      DC    F'0'                    BLDL RTN RETURN ADDR             16300013
CR9      DC    F'0'                    CTRLRECS RETURN ADDR             16310013
CT9      DC    F'0'                    CNTLRECS RETURN ADDR             16320013
RL9      DC    F'0'                    RLDRECS RETURN ADDR              16330013
TX9      DC    F'0'                    TXTFMT RETURN ADDR               16340013
POFSET   DC    F'0'                    OFFSET FOR TEXT PRINT            16350024
HIVAL    DC    4X'FF'                  CONSTANT F'S                     16360013
XZROS    DC    8X'00'                  CONSTANT ZEROS                   16370024
*                                                                       16380013
JFCBAD   DS    0F                      DCB EXIT LIST                    16390013
         DC    X'87'                   RDJFCB, END OF LIST              16400013
         DC    AL3(JFCB)               ADDRESS OF JFCB READ AREA        16410013
*                                                                       16420024
PROCESS  DC    XL1'00'                 PROCESS INDIC 80=SYM TBL BUILT   16430024
PRTABL   DC    CL9' '                  HEX-PRINTABLE CONVERSION AREA    16440024
*                                                                       16450013
JFCB     DC    CL176' '                JFCB                             16460013
SYMHDR   DC    C'     Symbol         Type  Ind Addr     Seg LRid  Lengt*16470028
               h  ESDid'                                            DSK 16480028
*                                                                       16490013
RLDHDR   DC    C'     Relptr  Posptr     Type      Len    Dir  Addr    *16500028
                     LMOD      Type'                                    16510028
*                                                                       16520013
PH1LBL   DC    C'***** Phase 1 Label Table *****'                   DSK 16530027
PH1HDR   DC    C'  Addr Type  Symbol Length'                        DSK 16540028
*                                                                       16550013
BLANX    DC    CL121' '                CONSTANT BLANKS                  16560013
TRTBL    DC    C'0123456789ABCDEF'     TRANSLATE TBL                    16570013
NOCNTRL  DC    C'Member and CSECT must be entered via SYSIN'            16580027
OVER8    DC    C'Member or CSECT name over 8 characters'                16590027
NOMEM    DC    C'No member name found in first control card'            16600033
INVMEM   DC    C'Specified member not found in SYSLIB PDS'              16610027
INVCSECT DC    C'Specified CSECT not found in member'                   16620027
FULLSYM  DC    C'Symbol table full: Over 5000 entries'                  16630027
FULLRLD  DC    C'RLD table full: Over 3000 entries'                     16640027
PRTCHAR  DC    256C'.'                 CHARACTER TRANSLATE TABLE        16650013
         ORG   PRTCHAR+C' '                                             16660013
         DC    C' '                                                     16670013
         ORG   PRTCHAR+C'A'                                             16680013
         DC    C'ABCDEFGHI'                                             16690013
         ORG   PRTCHAR+C'J'                                             16700013
         DC    C'JKLMNOPQR'                                             16710013
         ORG   PRTCHAR+C'S'                                             16720013
         DC    C'STUVWXYZ'                                              16730013
         ORG   PRTCHAR+C'0'                                             16740013
         DC    C'0123456789'                                            16750013
         ORG                                                            16760013
*                                                                       16770013
CTLSTMT  DC    CL80' '                 Saved control statement          16780030
SYSPUNCH DCB   DSORG=PS,MACRF=(PM,GM),DDNAME=SYSPUNCH,                 X16790013
               RECFM=FB,LRECL=80                                        16800013
SYSIN    DCB   DSORG=PS,MACRF=GL,DDNAME=SYSIN,                         X16810013
               RECFM=FB,LRECL=80,EODAD=NOCTL                            16820013
SYSLIB   DCB   DSORG=PO,MACRF=R,DDNAME=SYSLIB,                         X16830013
               RECFM=U,NCP=1                                            16840013
SYSPRINT DCB   DSORG=PS,MACRF=PM,DDNAME=SYSPRINT,                      X16850013
               RECFM=FBA,LRECL=121                                      16860013
LOADLIB  DCB   DSORG=PO,MACRF=R,DDNAME=LOADLIB,EXLST=JFCBAD             16870013
         DC    (((((*-UTL31)/256)+1)*256)-(*-UTL31))X'00'               16880033
****************************************************************        16890013
*                                                                       16900013
* FOLLOWING FIELDS: COMMPARM THRU COMMEND ARE COMMON AREAS SHARED       16910013
* BY THIS, AND CALLED SUB-PROGRAMS. ALL CHANGES MUST BE COORDINTAED     16920013
* WITH ALL OTHER PROGRAMS.                                              16930013
*                                                                       16940013
****************************************************************        16950013
COMMPARM CSECT ,                       COMMON AREAS                     16960032
DBLWD    DC    D'0'                    DOUBLEWORD WORK AREA             16970013
PUNCHDCB DC    A(SYSPUNCH)             @ SYSPUNCH DCB                   16980013
PRINTDCB DC    A(SYSPRINT)             @ SYSPRINT DCB                   16990013
INDCB    DC    A(SYSIN)                @ SYSIN DCB                      17000013
CSECT    DC    CL8' '                  SPECIFIED CSECT NAME             17010013
ESDID    DC    X'0001'                 ESD ID OF SPECIFIED CSECT        17020013
ENDLBLNM DC    CL8' '                  SYMBOL FOR END STMT BEGIN POINTE 17030013
LINECT   DC    PL2'0'                  PRINT LINE COUNTER               17040013
START    DC    F'0'                    LKED ASSIGNED START ADDR OF CSEC 17050013
END      DC    F'0'                    CSECT END ADDRESS                17060013
LENGTH   DC    F'0'                    LENGTH OF SPECIFIED CSECT        17070013
LBLTBL   DC    F'0'                    @ LABEL TABLE                    17080013
CURRLBL  DC    F'0'                    CURRENT LABEL ENTRY ADDR         17090013
ENDLBL   DC    F'0'                    @ END OF LABEL TBL               17100013
LBLLGTH  DC    AL2(L'LABEL)            LENGTH OF LABEL ENTRY         */ 17110013
TXTSTRT  DC    F'0'                    @ TEXT STORAGE AREA              17120013
TXTEND   DC    F'0'                    @ END OF TEXT AREA               17130013
TXTCURR  DC    F'0'                    @ CURRENT TEXT LOC               17140013
DTBCURR  DC    F'0'                    DSECT TABLE CURRENT ENTRY ADDR   17150013
DTBEND   DC    F'0'                    DSECT TABLE END ADDR             17160013
DTBSTRT  DC    A(HIVAL)                DSECT TABLE START ADDR           17170013
USGSTRT  DC    A(HIVAL)                USING TABLE START ADDR           17180013
USGCUR   DC    F'0'                    USING TABLE CURRENT ADDR         17190013
USGEND   DC    F'0'                    USING TABLE END ADDR             17200013
DATONLY  DC    F'0'                    DATA ONLY TABLE ADDR             17210013
DATOCUR  DC    F'0'                    CURRENT DATA ONLY ADDR           17220013
DATOEND  DC    F'0'                    END OF DATA ONLY TABLE           17230013
PRMOPT   DC    X'00'                                                DSK 17240013
FLPTASM  EQU   X'80'                   FLOATING POINT INDICATOR     DSK 17250013
PRIVASM  EQU   X'40'                   PRIVILEGED INDICATOR         DSK 17260013
DBGINSTR EQU   X'20'                   DEBUG(INSTR)                 DSK 17270013
DBGCONST EQU   X'10'                   DEBUG(CONST)                 DSK 17280013
DBGNOCMT EQU   X'08'                   DEBUG(NOCMT)                 DSK 17290013
DBGLABEL EQU   X'04'                   DEBUG(LABEL)                 DSK 17300013
CONALHEX EQU   X'02'                   DCNOCHAR                     DSK 17310013
CONNOLOW EQU   X'01'                   DCNOLOWER                    DSK 17320013
         DC    X'00'                                                DSK 17330013
USERR    DC    X'00'                   ERROR INDIC FOR DISASM1          17340013
NBRLBLS  DC    H'0'                    NBR LABELS FROM DISASM1          17350013
*                                                                       17360013
WORKREC  DS    0CL80                   DISASSEMBLY WORK AREA            17370013
NAME     DC    CL8' '                  NAME                             17380013
         DC    CL1' '                                                   17390013
MNEMONIC DC    CL5' '                  INSTRUCTION MNEMONIC             17400013
         DC    CL1' '                                                   17410013
OPNDS    DC    CL27' '                 1ST OPERAND                      17420013
         DC    CL1' '                                                   17430013
COMMENT  DC    CL28' '                 COMMENT                          17440013
COL72    DC    CL1' '                                                   17450013
SEQNBR   DC    CL8' '                  CARD SEQ NBR                     17460013
*                                                                       17470013
CARDNO   DC    PL4'0'                  OUTPUT CARD NBR                  17480013
PRTLINE  DS    0CL121                  PRINT LINE                       17490013
PCC      DC    C'1'                    CARRIAGE CONTROL                 17500013
PRT      DC    CL120' '                PRINT DATA                       17510013
*                                                                       17520013
         DC    0F'0'                                                    17530013
BLDLIST  DS    0CL62                   BLDL LIST                        17540013
         DC    H'1'                    ONE ENTRY                        17550013
         DC    H'58'                   LENGTH OF ENTRY                  17560013
MEMBER   DC    CL8' '                  MEMBER NAME                      17570013
TTRMOD   DC    XL3'0'                  TTR OF MODULE                    17580013
CCAT     DC    XL1'0'                  CONCATENATION NUMBER             17590013
         DC    XL1'0'                                                   17600013
ALIASIND DC    XL1'0'                  ALIAS AND MISC INDICATOR         17610013
*                           80=ALIAS                                    17620013
TTR1TXT  DC    XL3'0'                  TTR OF 1ST TXT RECORD            17630013
         DC    XL1'0'                                                   17640013
TTRNS    DC    XL3'0'                  TTR OF NOTE OR SCATTER LIST      17650013
NNOTE    DC    XL1'0'                  NBR ENTRIES IN NOTE LIST         17660013
ATTR1A   DC    XL1'0'                  MODULE ATTRIBUTES 1, BYTE 1      17670013
*                           80=RENT                                     17680013
*                           40=REUS                                     17690013
*                           20=OVERLAY                                  17700013
*                           10=UNDER TEST                               17710013
*                           08=ONLY LOADABLE                            17720013
*                           04=SCATTER FORMAT                           17730013
*                           02=EXECUTABLE                               17740013
*                           01=ONE TXT, NO RLD RECORDS                  17750013
ATTR1B   DC    XL1'0'                  ATTRIBUTES 1, BYTE 2             17760013
*                           80=CANNOT BE REPROCESSED BY LKED E          17770013
*                           40=ORIGIN OF 1ST TXT RECORD IS ZERO         17780013
*                           20=ASSIGNED ENTRY POINT ADDR IS ZERO        17790013
*                           10=CONTAINS NO RLD RECORD                   17800013
*                           08=CANNOT BE REPROCESSED BY LKED            17810013
*                           04=CONTAINS TESTRAN SYMBOLS                 17820013
*                           02=CREATED BY LKED                          17830013
*                           01=REFR                                     17840013
TOTVIRT  DC    XL3'0'                  TOTAL VIRTUAL STRG REQRD FOR MOD 17850013
LENG1    DC    XL2'0'                  LENGTH OF 1ST TEXT RECORD        17860013
LKEPA    DC    XL3'0'                  ASSIGNED ENTRY POINT ADDR        17870013
ATTR2    DC    XL1'0'                  ATTRIBUTES 2                     17880013
*                           80=PROCESSED BY OS/VS LKED                  17890013
*                           20=PAGE ALIGNMENT REQUIRED FOR MODULE       17900013
*                           10=SSI PRESENT                              17910013
         DC    XL2'0'                                                   17920013
SCTRLEN  DC    XL2'0'                  SCATTER LIST LENGTH              17930013
TTLEN    DC    XL2'0'                  TRANSLATION TABLE LENGTH         17940013
SCESDID  DC    XL2'0'                  CESD NBR FOR 1ST TXT RECD        17950013
SCEPESD  DC    XL2'0'                  CESD NBR FOR ENTRY POINT         17960013
ALEPA    DC    XL3'0'                  ENTRY POINT OF THE MEMBER NAME   17970013
ALMEM    DC    CL8' '                  REAL MEMBER NAME FOR ALIAS       17980013
SSI      DC    XL4'0'                  SSI BYTES                        17990013
AUTHLEN  DC    XL1'0'                  AUTH CODE LENGTH                 18000013
AUTHCOD  DC    XL1'0'                  AUTH CODE                        18010013
*                                                                       18020013
COMMEND  EQU   *                                                        18030013
         DC    (((((*-COMMPARM)/256)+1)*256)-(*-COMMPARM))X'00'         18040033
****************************************************************        18050014
*                                                              *        18060014
*                                                              *        18070014
*                                                              *        18080014
****************************************************************        18090014
RLDTBLD  DSECT ,                       RELOCATION DICTIONARY TABLE      18100014
RLDENT   DS    0CL20                   11 BYTE ENTRIES                  18110014
RLDRP    DS    XL2                     RELOCATION POINTER               18120014
RLDPP    DS    XL2                     POS PTR (SYMBOL CESD NBR)        18130014
RLDTYPE  DS    XL1                     TYPE                             18140014
*                    00=A-TYPE ADCON                                    18150014
*                    01=V-TYPE ADCON                                    18160014
*                    02=PSEUDO REGISTER DISPLACEMENT                    18170014
*                    03=PSEUDO REG CUMULATIVE DISPL                     18180014
*                    08=UNRESOLVED                                      18190014
RLDLEN   DS    XL1                     LENGTH OF CONSTANT               18200014
RLDDIR   DS    CL1                     RELOCATION DIRECTION, + OR       18210014
RLDADDR  DS    XL3                     LKED ASSGND ADDR OF CONSTANT     18220014
RLDNAME  DS    CL8                     NAME FROM ASSOC ESD              18230014
RLDESDTP DS    XL1                     TYPE FROM ASSOC ESD              18240014
         DS    XL1                                                      18250014
****************************************************************        18260014
*                                                              *        18270014
*                                                              *        18280014
*                                                              *        18290014
****************************************************************        18300014
SYMTBL   DSECT ,                       EXTERNAL SYMBOL TABLE ENTRY      18310014
SYMENT   DS    0CL19                   19 BYTE ENTRIES                  18320014
EXTSYM   DS    CL8                     EXTERNAL SYMBOL NAME             18330014
TYPSYM   DS    XL1                     SYMBOL TYPE                      18340014
*                        00=SD (NAMED CSECT)                            18350014
*                        02=ER (EXTRN)                                  18360014
*                        03=LR (ENTRY)                                  18370014
*                        04=PC (UNNAMED CSECT)                          18380014
*                        05=CM (COM)                                    18390014
*                        06=PR (PSEUDO REGISTER)                        18400014
*                        07=NULL                                        18410014
*                        0A=WX (WXTRN)                                  18420014
*                        0F=ENTAB OR SEGTAB                             18430014
SYMIND   DS    XL1                     INDICATOR                        18440014
*                        BIT 0 = MAP                                    18450014
*                        BIT 1 = CHAIN                                  18460014
*                        BIT 2 = INSERT                                 18470014
*                        BIT 3 = DELETE/REPLACE                         18480014
SYMADDR  DS    XL3                     SYMBOL ADDRESS (0 FOR ER, WX, NU 18490014
SYMSEG   DS    XL1                     SEGMENT ID (0 FOR ER, WX, NULL)  18500014
SYMLRID  DS    0XL2                    ESD ID OF DEF FOR LR             18510014
SYMLENG  DS    XL3                     LENGTH FOR SD, PC, CM, PR        18520014
*                        0 FOR ER, WX, NULL                             18530014
SYMESDID DS    XL2                     ESD ID OF THIS ITEM              18540014
****************************************************************        18550013
*                                                              *        18560014
*                                                              *        18570014
*                                                              *        18580014
****************************************************************        18590013
LABELD   DSECT ,                       LABEL TABLE ENTRY                18600000
LABEL    DS    0CL13                   13-BYTE ENTRIES                  18610000
LBLADR   DS    XL3                     RELATIVE ADDR IN TEXT            18620000
LBLTYP   DS    CL1                     TYPE:                          V 18630019
LBLTYPL  EQU   C'L'                          L=LABEL                    18640023
LBLTYPA  EQU   C'A'                          A=ADCON                    18650019
LBLTYPV  EQU   C'V'                          V=VCON                     18660019
LBLTYPW  EQU   C'U'                          W=WXTRN                    18670020
LBLTYPU  EQU   C'U'                          U=USER LABEL               18680020
LBLNAME  DS    CL8                     NAME (SYMBOL)                    18690000
LBLLEN   DS    XL1                     LENGTH IF A, V, OR W             18700000
****************************************************************        18710013
*                                                              *        18720014
*                                                              *        18730014
*                                                              *        18740014
****************************************************************        18750013
USINGD   DSECT ,                       USING TABLE ENTRY                18760000
USING    DS    0CL11                                                    18770000
USBGN    DS    XL3                     OFFSET TO BEGINNING OF RANGE     18780000
USEND    DS    XL3                     OFFSET TO END OF RANGE           18790000
USREG    DS    XL1                     BASE REGISTER USED               18800000
USTYPE   DS    XL1                     TYPE:P=PGM,D=DSECT               18810000
USVALU   DS    XL3                     BASE REG VALUE                   18820000
****************************************************************        18830013
*                                                              *        18840014
*                                                              *        18850014
*                                                              *        18860014
****************************************************************        18870013
DSECTD   DSECT ,                       DSECT FIELD TABLE ENTRY          18880000
DSECT    DS    0CL13                                                    18890000
DSOFSET  DS    XL3                     OFFSET TO 1ST BYTE OF FIELD      18900000
DSLBTYP  DS    CL1                     LABEL TYPE = L                   18910000
DSNAME   DS    CL8                     FIELD NAME                       18920000
DSLENG   DS    XL1                     FIELD LENGTH                     18930000
****************************************************************        18940014
*                                                              *        18950014
*                                                              *        18960014
*                                                              *        18970014
****************************************************************        18980014
DTBD     DSECT ,                       DSECT TABLE ENTRY                18990014
DTB      DS    0CL11                                                    19000014
DTBNAM   DS    XL8                     DSECT NAME                       19010014
DTBFLD@  DS    AL3                     DSECT FIELD TABLE ADDRESS        19020014
****************************************************************        19030016
*                                                              *        19040016
*                                                              *        19050016
*                                                              *        19060016
****************************************************************        19070016
DTAD     DSECT ,                       DATA TABLE ENTRY                 19080016
DTA      DS    0XL6                                                     19090016
DTABGN   DS    AL3                     DATA BEGIN OFFSET                19100016
DTAEND   DS    AL3                     DATA END OFFSET                  19110016
         END                                                            19120000
