         TITLE 'IGC084  ---- STORE BUFFER RESTART ADDRESS'  D11         03000000
*STATUS: CHANGE LEVEL 000                                               06000002
*FUNCTION/OPERATION: STORES THE BUFFER RESTART ADDRESS IN THE UCB       09000002
*ENTRY POINT:  IGC084                                       D11         12000000
*INPUT: IN REGISTER 0 -THE 16 HIGH ORDER BITS CONTAIN THE BUFFER        14000000
*   RESTART ADDRESS; THE 16 LOW ORDER BITS CONTAIN THE ADDRESS OF       16000000
*   THE UCB.                                                            18000000
*       IN REGISTER 1-ADDRESS DCB                            LG @ZM2358 21050000
*OUTPUT: THE BUFFER RESTART ADDRESS STORED IN THE UCB                   24000002
*EXTERNAL ROUTINES: DEBCHK(VIA BRANCH ENTRY)                D11         27000000
*EXITS-NORMAL: RETURN TO GIOCR VIA REG14                                30000002
*     -ERRORS: NONE                                                     33000002
*TABLES/WORK AREAS: NONE                                                36000002
*ATTRIBUTES: TYPE 1, RESIDENT, SUPERVISOR STATE, REENTRANT              39000002
*NOTES - NONE                                                           42000002
         EJECT                                                          45000002
IGC084   CSECT                                                          48000002
*C630000,840000                                               LF YM4067 48050002
*A84100-849500,A720500-723000,A540500-54900,A550000          LG @ZM2358 48060000
*D570000-630000                                              LG @ZM2358 48070000
*A547650-547950,660200,847200                               D11 ZA04879 48080000
*C546000-546500,A547000                                     D11 ZA04880 48090000
*A547960-547980,A660300                                     D11 ZA13198 48990000
*A54220002,C54760002,A72125002                              D11 ZA13201 49890000
         EJECT                                              D11         51000000
         USING *,R6                                             DSK1097 54000010
         B     MODID               HOP AROUND EYECATCHER                54010000
         DC    C'IGC084  .MVS GAM04/08/80*00990460UZ31164'      DSK1097 54040000
MODID    DS    0H                                               DSK1097 54070000
         IC    R15,TCBPKF-TCB(,R4)                              DSK1097 54070010
         SPKA  0(R15)                                           DSK1097 54070020
         LR    R8,R0            SAVE REGISTER 0                 DSK1097 54070030
         USING CVT,R3              BASE FOR CVT                 DSK1097 54250000
         L     R2,UCBBSTR(,R1)                                  DSK1097 54501010
         CLM   R1,7,DCBDEB+1(R2)                                DSK1097 54501020
         BNE   A000094                                          DSK1097 54501030
         LA    R2,0(,R1)                                        DSK1097 54501040
         LR    R1,R2                                            DSK1097 54501050
         LA    R10,0(R4)                                        DSK1097 54501060
         L     R15,CVTEXT2                                      DSK1097 54550010
         USING CVTXTNT2,R15                                     DSK1097 54550020
         L     R15,CVTDEBVR          LD ADDR DEBVERIFY          DSK1097 54560000
         DROP  R15                                              DSK1097 54560010
         LR    R12,R14                                          DSK1097 54560020
         BALR  R14,R15             GO TO DEB VERIFY             DSK1097 54580000
         B     GOODEB              DEB IS GOOD (+0)         D11 ZA04880 54600000
         LR    R14,R12                                          DSK1097 54660010
         SPKA  0                                                DSK1097 54660020
         BR    R14                                              DSK1097 54660030
GOODEB   DS    0H                                               DSK1097 54690010
         LR    R14,R12                                          DSK1097 54761010
         SPKA  0                                                DSK1097 54761020
         LR    R1,R2                                            DSK1097 54761030
         L     R9,DEBUCB-1(,R1)                                 DSK1097 54761040
         CLC   GUCBTYP(2,R9),G2250 PASSED UCB A 2250?           DSK1097 54761050
         BNER  R14                 NO,SORRY BOUT THAT           DSK1097 54761060
         SR    R11,R11             FOR IC                   D11 YA04879 54765000
         IC    R11,NUMUCB(,R1)     GET NUMUCBS FROM DEB         DSK1097 54770010
         SLL   R11,2               X4(EACH DSCRPTR 4 LONG)  D11 YA04879 54775000
         LA    R11,32(R11,R1)  DEBADR+DEBLEN+NUMUCBS(EACH4)     DSK1097 54780010
* PREV INSTR POINTS R11 TO 1ST SBRTN LOADED BY OPEN         D11 YA04879 54785000
         CLC   0(2,R11),SBNAME     BETTER BE 'OA'!!         D11 YA04879 54790000
         BNER  R14    ITS NOT,SO NOT GAM,SO INVALID DEB         DSK1097 54795010
         STH   R8,UCBBSTR(R9)        STR RESTART ADDRESS        DSK1097 54900000
LEAVE    EQU   *                                                        54950000
         BR    R14                    RETURN TO GIOCR           DSK1097 66000002
A000094  SPKA  0                                                DSK1097 66001010
         BR    R14                                              DSK1097 66001020
SBNAME   DC    C'OA' LST 2CHRS 1ST GAM MOD LOADED BY OPEN   D11 YA04879 66020000
G2250    DC    X'1002'             2250 DEVTYPE IN UCB      D11 ZA13198 66030000
         DC    X'60A6'                       !!! SOURCE COMPARE FIX !!! 66050000
PATCH    DC    0F'0'                                            DSK1097 66050000
         DC    40X'FF'            40 BYTE PATCH AREA        D11 @ZM2358 67050000
R2       EQU   2              SAFE HOLDER FOR DEBADDR       D11 ZA13201 72120000
R5       EQU   5                                             LG @ZM2358 72250000
R6       EQU   6                  GENERAL REG 6              LG @ZM2358 72260000
SIXTEEN  EQU   16                       CONSTANT                        81000002
UCBBSTR  EQU   24              BUFFER RESTART ADDR            LF YM4067 84000002
GUCBTYP  EQU   18                  UCBTYPE DISPL IN UCB     D11         84100000
R8       EQU   8                     WORK REGISTER           LG @ZM2358 84120000
R9       EQU   9                     WORK REGISTER           LG @ZM2358 84150000
R11      EQU   11                    WORK REGISTER           LG @ZM2358 84250000
R15      EQU   15                    WORK REGISTER           LG @ZM2358 84300000
SEVEN    EQU   7                       VALUE OF 7            LG @ZM2358 84600000
DEBUCB   EQU   33                      DISP OF UCB IN DEB    LG @ZM2358 84650000
DCBDEB   EQU   44                      DISP DEB IN DCB       LG @ZM2358 84700000
NUMUCB   EQU   16     DISPL IN DEB OF NUMUCBS BYTE          D11 YA04879 84720000
CRNTASCB EQU   12                                            LG @ZM2358 84750000
CRRNTTCB EQU   4                                             LG @ZM2358 84850000
CVT      DSECT                                               LG @ZM2358 84900000
         CVT   LIST=YES                                      LG @ZM2358 84950000
         IKJTCB LIST=YES                                        DSK1097 84950010
         DCBD  ,                                                DSK1097 84950020
R0       EQU   0                       REGISTER 0               DSK1097 84950021
R1       EQU   1                       REGISTER 1               DSK1097 84950022
R3       EQU   3                       REGISTER 3               DSK1097 84950023
R4       EQU   4                       REGISTER 4               DSK1097 84950024
R7       EQU   7                       REGISTER 7               DSK1097 84950025
R10      EQU   10                      REGISTER 10              DSK1097 84950026
R12      EQU   12                      REGISTER 12              DSK1097 84950027
R13      EQU   13                      REGISTER 13              DSK1097 84950028
R14      EQU   14                      REGISTER 14              DSK1097 84950029
         END   ,                                                DSK1097 87000002
