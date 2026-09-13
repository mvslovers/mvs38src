         TITLE 'GRAPHIC ATTENTION SERVICE ROUTINE'                      00020002
*********************************************************************** 00032002
*                                                                       00034002
* MODULE NAME:           IGC070 (OS/VS2)                                00036002
*                                                                       00038002
* DESCRIPTIVE NAME:      GRAPHIC ATTENTION SERVICE ROUTINE              00038402
*                                                                       00038802
* COPYRIGHT:             NONE                                           00039202
*                                                                       00039602
* STATUS:                RELEASE 2.0                                    00039702
*                                                                       00039802
* FUNCTION:              THIS MODULE PERFORMS FUNCTIONS FOR             00039902
*FILL IN FROM SPECS******CONTINUED*NEXT*PAGE*************************** 00046602
         EJECT                                                          00048602
IGC070   CSECT                                                          00049002
*   SEE LABEL 'MODID' FOR LAST CHANGE DATE; FORMAT:  NAME.SYSREL.DATE   00050602
* SEQ NBRS MUST BE RESPECIFIED BECAUSE OF RESEQ FOR VS                  00051002
*C010000                                                         Y01021 00053200
*A007100,A009820,A010120                                     LD YA00813 00054200
*A008240-008280,A007120-007180,A009920-010200                LG @ZM2359 00055200
*A005700,A006300,A006500,A006900                             LG @ZM2359 00056200
*C010100-010130,A010160                                     D11 ZA04881 00057200
*A008290,A010350-010800                                     D11 ZA04882 00058200
*C012000,A012200-012240,015430-015460                       D11 ZA13197 00059200
*C010250                                                    E12 ZA25652 00059800
*A011205,A012185,A015925                                    E12 ZA26470 00060400
*                                                                       00061000
*                                                                       00061902
*STATUS:CHANGE LEVEL 0                                                  00066602
*FUNCTION/OPERATION:THIS ROUTINE RESETS TO 0  BIT 6 OR BIT 7 OR BOTH    00073302
*   THAT ARE LOCATED IN THE GRAPHIC CONTROL BYTE APPENDAGE TO THE       00080002
*   UNIT CONTROL BLOCK(UCB).                                            00100002
*ENTRY POINTS:SVC  070  OR USE GSERV MACRO.RESET BITS 6 AND/OR 7 IN GCB 00120002
*INPUT:GR#1 IS THE PARAMETER REGISTER.ITS CONTENTS ARE AS FOLLOWS:      00140002
*   ******************                                                  00160002
*   MASK*DCBLIST ADR*  MASK=01 FOR BIT7,02 FOR BIT6,03 FOR BOTH.        00180002
*   ******************                                                  00200002
*   DCBLIST ADR CONTAINS THE FOLLOWING INFORMATION:                     00220002
*   ****************                                                    00240002
*   * IX * DCB ADR * IX=DEB EXTENT TO ACCESS UCB ADDRESS.               00260002
*   ****************                                                    00280002
*OUTPUT:N/A                                                             00300002
*EXTERNAL ROUTINES:DEBVERIFY VIA BRANCH ENTRY.                          00320000
*EXITS NORMAL:RETURN MADE TO CALLING ROUTINE VIA SVC 3.                 00340002
*EXITS ERROR:ABNORMAL TERMINATION OF TASK.SYSTEM COMPLETION CODES ARE   00360002
*   AS FOLLOWS:                                                         00380002
*               056=INVALID UNIT CONTROL BLOCK(UCB).                    00400002
*               057=NOT A GRAPHIC UCB.                                  00420002
*TABLES/WORK AREAS:N/A                                                  00440002
*ATTRIBUTES:RE-ENTRANT                                                  00460002
*NOTES:N/A                                                              00480002
         EJECT                                                          00552002
*                                                                       00554002
*                                  STANDARD SYSTEM REGISTERS ---        00556002
*                                                                       00558002
R1       EQU   1                       WORK REGISTER         LG @ZM2359 00570000
R8       EQU   8                  WORK REGISTER              LG @ZM2359 00702000
R0       EQU   0                     WORK REGISTER           LG @ZM2359 00712000
R11      EQU   11                    WORK REGISTER           LG @ZM2359 00714000
R14      EQU   14                    WORK REGISTER           LG @ZM2359 00716000
R15      EQU   15                 GENERAL REGISTER 15        LG @ZM2359 00718400
R2       EQU   2                       REGISTER 2               DSK1107 00718401
R3       EQU   3                       REGISTER 3               DSK1107 00718402
R4       EQU   4                       REGISTER 4               DSK1107 00718403
R5       EQU   5                       REGISTER 5               DSK1107 00718404
R6       EQU   6                       REGISTER 6               DSK1107 00718405
R7       EQU   7                       REGISTER 7               DSK1107 00718406
R9       EQU   9                       REGISTER 9               DSK1107 00718407
R10      EQU   10                      REGISTER 10              DSK1107 00718408
R12      EQU   12                      REGISTER 12              DSK1107 00718409
R13      EQU   13                      REGISTER 13              DSK1107 00718410
*                                                                       00720002
*          CONSTANTS USED IN THIS MODULE                              * 00722002
*                                                                     * 00724002
ZERO     EQU   0                       ZERO DISPLACEMENT      LB Y01021 00730002
UCBADR   EQU   32                       START OF UCB LIST IN DEB        00740002
DEBADR   EQU   44                       START OF DEB ADDRESS IN DCB     00760002
EXIT     EQU   3                                                        00800002
RC4      EQU   4                     RETCD VALUE OF 4        LG @ZM2359 00824000
CRNTASCB EQU   12                                            LG @ZM2359 00826000
CRRNTTCB EQU   4                                             LG @ZM2359 00828000
NUMUCB   EQU   16                  DISPL IN DEB OF NUMUCBS  D11 ZA04882 00829000
         EJECT                                                          00830002
SVC070   DC    0D'0'           ALIGN SVC TO A DBLE WORD BNDRY   DSK1107 00880002
         USING *,R6                                             DSK1107 00920010
         B     MODID2              HOP AROUND EYECATCHER                00930000
MODID    DC    C'IGC070  .MVS GAM04/08/80 00990456UZ31164'      DSK1107 00940000
MODID2   DS    0H                 LOAD DCB ADDR AND INDX FACTR  DSK1107 00950010
         IC    R15,TCBPKF-TCB(,R4)                              DSK1107 00980010
         SPKA  0(R15)                                           DSK1107 00980020
         L     R2,0(,R1)           LOAD DCB ADDR AND INDX FACTR DSK1107 00980030
         LR    R9,R1               SAVE REG1                    DSK1107 00982002
         L     R1,DEBADR(R2)                                    DSK1107 00982010
         LA    R1,0(,R1)                                        DSK1107 00982020
         SPKA  0                                                DSK1107 00982030
         LR    R8,R14                SAVE REG 14             LG @ZM2359 00992000
         USING CVT,R3                                           DSK1107 00996010
         USING CVTXTNT2,R5         BASE FOR CVT EXT2            DSK1107 00998000
         L     R5,CVTEXT2          LD ADDR CVT EXT2             DSK1107 00998800
         LA    R10,0(,R4)                                       DSK1107 00999210
         L     R15,CVTDEBVR        LD ADDR DEB VERIFY           DSK1107 00999800
         SR    R0,R0                   CLEAR REGISTER        LG @ZM2359 00999900
         BALR  R14,R15             GO DO DEBVERIFY              DSK1107 01004900
         B     GOODCB              DEB IS VALID (+0)        D11 ZA04881 01010000
         LR    R14,R8              RESTORE R14              D11 ZA04881 01013000
         B     BADDCB              DEB INVALID              D11 ZA04881 01016000
GOODCB   LR    R14,R8              RESTORE R14              D11 ZA04881 01019000
         LR    R0,R1                                            DSK1107 01025010
         LR    R1,R9               RESTORE REG1                 DSK1107 01030002
         LR    R9,R0                                            DSK1107 01030010
         SRL   R2,24                                            DSK1107 01030020
         CLM   R2,1,NUMUCB(R9)     USERUCB GT DEBUCB?           DSK1107 01032010
         BH    BADDCB              YES,INVALID PARAMETER    D11 ZA04882 01042000
         SLL   R2,2                X4(EACH UCB IN DEB LN=4)     DSK1107 01052010
         L     R8,UCBADR(R2,R9)    LOAD UCB ADDR                DSK1107 01062010
         TM    UCBID-UCB(R8),UCBSTND TEST FOR VALID UCB ID      DSK1107 01100010
         BO    GCBCHK                   BRANCH IF VALID     D11         01120000
*        SETLOCK RELEASE,TYPE=LOCAL,RELATED=(IEAVESVC)          DSK1107 01123000
*        WTO   'IFF421I GSERV FOUND INVALID UCB',               DSK1107X01126002
               ROUTCDE=11,DESC=7                                 S21016 01132002
*        ABEND (1),DUMP                                         DSK1107 01180002
BADDCB   EQU   *                                             LG @ZM2359 01182000
         LA    R15,RC4               LD RETCD OF 4           LG @ZM2359 01184000
         BR    R14                   RETURN                  LG @ZM2359 01186000
         EJECT                                                          01190002
GCBCHK   CLC   UCBDVCLS-UCB(2,R8),G2250 IS UCB FOR A 2250?      DSK1107 01200010
         BE    RESET                    BRANCH IF VALID UCB D11 ZA13197 01206000
         CLC   UCBDVCLS-UCB(2,R8),G2260 IS UCB FOR A 2260?      DSK1107 01212010
         BE    RESET                    BRANCH IF VALID UCB D11 ZA13197 01218000
*        SETLOCK RELEASE,TYPE=LOCAL,RELATED=(IEAVESVC)          DSK1107 01222000
*        WTO   'IFF422I DEVICE NOT SUPPORTED BY GAM',           DSK1107X01226000
               ROUTCDE=11,DESC=7                                 S21016 01232002
*        ABEND (1),DUMP                                         DSK1107 01280002
         LA    R15,RC4                                          DSK1107 01280010
         BR    R14                                              DSK1107 01280020
RESET    SRL   R1,24               POSITION BIT INDICATOR       DSK1107 01300002
         LA    R3,3                LOAD PROTECT MASK FOR GRAPH  DSK1107 01320002
*                                       SUPERVISOR BITS IN GCB          01340002
         NR    R1,R3               MASK OUT ANY USER REQUEST    DSK1107 01360002
*                                       RESET PROTECTED GRAPHIC         01380002
*                                       SUPERVISOR BITS IN GCB          01400002
         LA    R3,X'FF'            LOAD INITIAL RESET MASK      DSK1107 01420002
         XR    R1,R3               DETERMINE FINAL RESETMASK    DSK1107 01440002
         IC    R3,UCBGCB-UCB(,R8)                               DSK1107 01460010
         NR    R1,R3               RESET SPECIFIED GCB BITS     DSK1107 01480002
         STC   R1,UCBGCB-UCB(,R8)  STORE NEW GCB BYTE           DSK1107 01500010
         LA    R15,0                                            DSK1107 01520010
         BR    R14                                              DSK1107 01540002
G2250    DC    X'1002'             UCBTYPE FOR 2250         D11 ZA13197 01543000
G2260    DC    X'1003'             UCBTYPE FOR 2260         D11 ZA13197 01546000
         DC    X'B20A'                       !!! SOURCE COMPARE FIX !!! 01550000
PATCH    DC    0F'0'               40 BYTE PATCH AREA           DSK1107 01550000
         DC    40X'FF'                                      D11         01560000
         NOPR  0                                                DSK1107 01580010
         NOPR  0                                                DSK1107 01580020
         EJECT                                                          01590002
         CVT   DSECT=YES                                                01592002
         IHAPSA                                             E12 ZA26470 01596000
         IKJTCB LIST=YES                                        DSK1107 01596001
UCB      DSECT ,                                                DSK1107 01596002
         IEFUCBOB LIST=YES                                      DSK1107 01596003
         END   ,                                                DSK1107 01600002
