ESPU     TITLE 'BLSRESPU--ADD AN EQUATE SYMBOL RECORD                  *00001000
                        '                                               00002000
*/* CHANGE ACTIVITY -------------------------------------------------*/ 00003000
*/*   THIS MODULE WAS WRITTEN FOR @G57LPRW                           */ 00004000
*/*------------------------------------------------------------------*/ 00005000
BLSRESPU CSECT ,                                                01S0002 00006000
@MAINENT DS    0H                                               01S0002 00007000
         USING *,@15                                            01S0002 00008000
         B     @PROLOG                                          01S0002 00009000
         DC    AL1(23)                                          DSKC069 00010000
         DC    C'BLSRESPU 81066 UZ35265 '                       DSKC069 00011000
         DROP  @15                                                      00012000
@PROLOG  STM   @14,@12,12(@13)                                  01S0002 00013000
         BALR  @12,0                                            01S0002 00014000
@PSTART  DS    0H                                               01S0002 00015000
         USING @PSTART,@12                                      01S0002 00016000
         L     @00,@SIZDATD                                     01S0002 00017000
         BLSUALLS R,LV=(0)                                              00018000
         LR    @11,@01                                          01S0002 00019000
         USING @DATD,@11                                        01S0002 00020000
         ST    @13,@SA00001+4                                   01S0002 00021000
         LM    @00,@01,20(@13)                                  01S0002 00022000
         ST    @11,8(,@13)                                      01S0002 00023000
         MVC   @PC00001(8),0(@01)                               01S0002 00025000
*   CALL BLSRESCK;                  /* VALIDATE EQUATE SYMBOL RECORD */ 00026000
         L     @06,ZZ2RVTP(,@09)                                DSKC069 00027000
         LR    @13,@11                                          DSKC069 00027010
         L     @15,RVTESCKP(,@06)                               DSKC069 00028000
         BALR  @14,@15                                          01S0133 00029000
         LR    @07,@15                                          DSKC069 00029010
*   RESPECIFY                                                   01S0134 00030000
*    (R1) UNRESTRICTED;             /* ->PARAMETER LIST              */ 00031000
*   IF RF=ZZZFLAGI THEN             /* VALID EQUATE SYMBOL RECORD    */ 00032000
*                                                               01S0135 00033000
         LTR   @15,@15                                          DSKC069 00034000
         BNZ   @RF00135                                         01S0135 00035000
*     /***************************************************************/ 00036000
*     /*                                                             */ 00037000
*     /* VALID EQUATE SYMBOL RECORD                                  */ 00038000
*     /*                                                             */ 00039000
*     /***************************************************************/ 00040000
*                                                               01S0136 00041000
*     DO;                           /* VALID EQUATE SYMBOL RECORD    */ 00042000
*       RESPECIFY                                               01S0137 00043000
*        (R2,                       /* RECORD LENGTH                 */ 00044000
*         R3,                       /* ->ACB                         */ 00045000
*         R4,                       /* ->RECORD AREA AND KEY         */ 00046000
*         R5,                       /* RECORD LENGTH                 */ 00047000
*         RA) RESTRICTED;           /* ->RPL                         */ 00048000
*       R2=ESPALKL;                 /* KEY LENGTH                    */ 00049000
         L     @06,ZZ2ZZ1P(,@09)                                DSKC069 00050000
*       R3=ZZ1ACBP;                 /* ->ACB                         */ 00051000
         LA    @02,59                                           DSKC069 00052000
         L     @03,ZZ1ACBP(,@06)                                DSKC069 00053000
*       R4=ADDR(ESPA);              /* ->RECORD AREA AND KEY         */ 00054000
         L     @04,@PC00001+4                                   DSKC069 00055000
*       R5=ESPALRL+ESPARL;          /* RECORD LENGTH                 */ 00056000
         L     @06,@PC00001+4                                   DSKC069 00057000
         LA    @05,182                                          DSKC069 00058000
         SLR   @08,@08                                          01S0141 00059000
         ICM   @08,3,ESPARL(@06)                                DSKC069 00060000
         ALR   @05,@08                                          DSKC069 00061000
*       RA=ADDR(MYRPLA);            /* ->RPL                         */ 00062000
         LA    @10,MYRPLA                                       DSKC069 00063000
*       GENERATE SETS(GENPARM) CODE;                            01S0143 00064000
*/*-------------------------------------------------------------------* 00065000
*   CREATE AN RPL TO ADD THE EQUATE SYMBOL RECORD                     * 00066000
*---------------------------------------------------------------------* 00067000
         GENCB BLK=RPL,WAREA=(@10),LENGTH=256,KEYLEN=(@02),     DSKC069*00068000
               ACB=(@03),AREA=(@04),RECLEN=(@05),               DSKC069*00069000
               OPTCD=(DIR,MVE),MF=(L,GENPARM,GENPARML)          DSKC069 00070000
*       RESPECIFY                                               01S0144 00071000
*        (R2,                       /* RECORD LENGTH                 */ 00072000
*         R3,                       /* ->ACB                         */ 00073000
*         R4,                       /* ->RECORD AREA AND KEY         */ 00074000
*         R5) UNRESTRICTED;         /* KEY LENGTH                    */ 00075000
*       CALL BLSUVSCR(ZZ2,GENPARM); /* CREATE AN RPL                 */ 00076000
         ST    @09,@AL00001                                     DSKC069 00077000
         LA    @14,GENPARM                                      01S0145 00078000
         ST    @14,@AL00001+4                                   01S0145 00079000
         L     @06,ZZ2BVTP(,@09)                                DSKC069 00080000
         LA    @01,@AL00001                                     DSKC069 00081000
         L     @15,BVTVSCRP(,@06)                               DSKC069 00082000
         BALR  @14,@15                                          01S0145 00083000
*       IF RF=ZZZFLAGI THEN         /* GENCB SUCCESSFUL              */ 00084000
         LTR   @15,@15                                          DSKC069 00085000
         BNZ   A000144                                          DSKC069 00086000
*         CALL BLSUVSPU(ZZ2,MYRPLB);/* ADD THE RECORD                */ 00087000
         ST    @09,@AL00001                                     DSKC069 00088000
         ST    @10,@AL00001+4                                   DSKC069 00089000
         L     @06,ZZ2BVTP(,@09)                                DSKC069 00090000
         LA    @01,@AL00001                                     DSKC069 00091000
         L     @15,BVTVSPUP(,@06)                               DSKC069 00092000
         BALR  @14,@15                                          01S0147 00093000
A000144  CR    @07,@15                                          DSKC069 00093020
         BNL   A00024C                                          DSKC069 00093030
         LR    @07,@15                                          DSKC069 00093040
A00024C  L     @06,@PC00001+4                                   DSKC069 00093050
         CLC   ZZ2AMDU(31,@06),A0001E8                          DSKC069 00093060
         BNE   A0001B6                                          DSKC069 00093070
         L     @08,ZZ2AZZ6P(,@09)                               DSKC069 00093080
         L     @14,ESPALAD(,@06)                                DSKC069 00093090
         AL    @14,ESPAD(,@06)                                  DSKC069 00093100
         ST    @14,ZZ6DPRP(,@08)                                DSKC069 00093110
         L     @00,ESPADIM(,@06)                                DSKC069 00093120
         LA    @01,1                                            DSKC069 00093130
         CLR   @00,@01                                          DSKC069 00093140
         BNL   A00017A                                          DSKC069 00093150
         LR    @00,@01                                          DSKC069 00093160
A00017A  LR    @03,@00                                          DSKC069 00093170
         M     @02,ESPADLE(,@06)                                DSKC069 00093180
         ALR   @14,@03                                          DSKC069 00093190
         ST    @14,ZZ6DCAP(,@08)                                DSKC069 00093200
         MVC   ZZ2PGM(8,@09),A0001E0                            DSKC069 00093210
         ST    @09,@AL00001                                     DSKC069 00093220
         LA    @06,ZZ6D(,@08)                                   DSKC069 00093230
         ST    @06,@AL00001+4                                   DSKC069 00093240
         L     @08,ZZ2BVTP(,@09)                                DSKC069 00093250
         LA    @01,@AL00001                                     DSKC069 00093260
         L     @15,BVTPGMCP(,@08)                               DSKC069 00093270
         BALR  @14,@15                                          DSKC069 00093280
         CR    @07,@15                                          DSKC069 00093290
         BNL   A0001AE                                          DSKC069 00093300
         LR    @07,@15                                          DSKC069 00093310
*     END;                          /* VALID EQUATE SYMBOL RECORD    */ 00094000
*   ELSE                            /* INVALID RECORD                */ 00095000
*     RF=ZZZFLAGT;                  /* RETURN CODE                   */ 00096000
A0001AE  B     A0001B6                                          DSKC069 00097000
@RF00135 LA    @07,16                                           DSKC069 00098000
*   RETURN CODE(RF);                                            01S0150 00099000
A0001B6  DS    0H                                               DSKC069 00099010
*                                                               01S0150 00100000
         L     @13,4(,@13)                                      01S0150 00102000
         L     @00,@SIZDATD                                     01S0150 00103000
         LR    @01,@11                                          01S0150 00104000
         BLSUFRES R,LV=(0),A=(1)                                        00105000
         LR    @15,@07                                          DSKC069 00106000
         L     @14,12(,@13)                                     01S0150 00107000
         LM    @00,@12,20(@13)                                  01S0150 00108000
         BR    @14                                              01S0150 00109000
*/*BLSRPEND--DEBUGGING MODULE                                        */ 00110000
*/*BLSUPEND--MVS IPCS MODULE                                         */ 00111000
*                                                               01S0151 00112000
*   DECLARE                         /* COMMON VARIABLES              */ 00113000
*     I256C CHAR(256) BASED,                                    01S0151 00114000
*     I031F FIXED(31) BASED,                                    01S0151 00115000
*     I031P PTR(31) BASED,                                      01S0151 00116000
*     I015F FIXED(15) BASED,                                    01S0151 00117000
*     I015P PTR(15) BASED,                                      01S0151 00118000
*     I008P PTR(8) BASED,                                       01S0151 00119000
*     I001C CHAR(1) BASED;                                      01S0151 00120000
*   GENERATE NODEFS NOREFS DATA;                                01S0152 00121000
*   END BLSRESPU                    /* BLRPEND(BLSRESPU)             */ 00122000
*                                                               01S0153 00123000
*/* THE FOLLOWING INCLUDE STATEMENTS WERE FOUND IN THIS PROGRAM.     */ 00124000
*/*%INCLUDE SYSLIB  (BLSRZZZ )                                       */ 00125000
*/*%INCLUDE SYSLIB  (BLSUZZZ )                                       */ 00126000
*/*%INCLUDE SYSLIB  (BLRFULL )                                       */ 00127000
*/*%INCLUDE SYSLIB  (IKJCPPL )                                       */ 00128000
*/*%INCLUDE SYSLIB  (IKJPSCB )                                       */ 00129000
*/*%INCLUDE SYSLIB  (IKJECT  )                                       */ 00130000
*/*%INCLUDE SYSLIB  (IKJUPT  )                                       */ 00131000
*/*%INCLUDE SYSLIB  (BLSUSERV)                                       */ 00132000
*/*%INCLUDE SYSLIB  (BLRSERV )                                       */ 00133000
*/*%INCLUDE SYSLIB  (BLRSERVD)                                       */ 00134000
*/*%INCLUDE SYSLIB  (BLSRSERV)                                       */ 00135000
*                                                               01S0153 00136000
*       ;                                                       01S0153 00137000
         DC    X'60A0'                       !!! SOURCE COMPARE FIX !!! 00144000
@DATA    DS    0H                                                       00144000
@DATD    DSECT                                                          00145000
         DS    0F                                                       00146000
@SA00001 DS    18F                                                      00147000
@PC00001 DS    2F                                                       00148000
@AL00001 DS    2A                                                       00149000
BLSRESPU CSECT                                                          00150000
         DS    0F                                                       00151000
@DATD    DSECT                                                          00152000
         DS    0D                                                       00153000
MYRPLA   DS    CL256                                                    00154000
BLSRESPU CSECT                                                          00155000
         DS    0F                                                       00156000
@SIZDATD DC    AL1(0)                                                   00157000
         DC    AL3(@ENDDATD-@DATD)                                      00158000
         DS    0D                                                       00159000
@DATD    DSECT                                                          00160000
         SPACE 2                                                        00161000
*********************************************************************** 00162000
* THE FOLLOWING AREA, BLRPATCH, IS RESERVED FOR PATCH APPLICATION     * 00163000
* TO OBTAIN PATCH ROOM IN THE @DATD AUTOMATIC STORAGE AREA, MODIFY    * 00164000
* CONSTANT @SIZDATD TO REFLECT THE DESIRED @DATD SIZE                 * 00165000
*********************************************************************** 00166000
         SPACE                                                          00167000
BLSRESPU CSECT                                                          00168000
         ORG                                                            00169000
         DC    0D'0'                                            DSKC069 00170000
A0001E0  DC    C'BLSRRDAR'                                      DSKC069 00171000
A0001E8  DC    CL31'PRIVATE'                                    DSKC069 00171010
         DC    X'14'                         !!! SOURCE COMPARE FIX !!! 00171020
         DC    0D'0'                                            DSKC069 00171020
BLRPATCH DC    C'ZAPAREA 81066   '                              DSKC069 00171030
         DC    C'BLSRESPU UZ35265'                              DSKC069 00171040
         DC    C'BLSRESPU UZ35265'                              DSKC069 00171050
@DATD    DSECT                                                          00172000
         DS    0H                                                       00173000
@DATD    DSECT                                                          00174000
*---------------------------------------------------------------------* 00175000
*   RESERVE SPACE FOR A GENCB PARAMETER LIST                          * 00176000
*---------------------------------------------------------------------* 00177000
GENPARM  DS    (GENPARML)CL1           GENCB PARAMETER LIST             00178000
@DATD    DSECT                                                          00179000
         SPACE 2                                                        00180000
*********************************************************************** 00181000
* ALIGN END OF DATA ON A DOUBLEWORD BOUNDARY                          * 00182000
*********************************************************************** 00183000
         SPACE                                                          00184000
         DS    0D                                                       00185000
@DATD    DSECT                                                          00186000
         ORG   *+1-(*-@DATD)/(*-@DATD) INSURE DSECT DATA                00187000
@ENDDATD EQU   *                                                        00188000
BLSRESPU CSECT                                                          00189000
         BLSZZ1  ,                                              DSKC069 00189010
         BLSZZ2  ,                                              DSKC069 00189020
         BLSBVT  ,                                              DSKC069 00189030
         BLSZZ6  ,                                              DSKC069 00189040
         BLSRVT  ,                                              DSKC069 00189050
         BLSESPA ,                                              DSKC069 00189060
@00      EQU   00                      EQUATES FOR REGISTERS 0-15       00190000
@01      EQU   01                                                       00191000
@02      EQU   02                                                       00192000
@03      EQU   03                                                       00193000
@04      EQU   04                                                       00194000
@05      EQU   05                                                       00195000
@06      EQU   06                                                       00196000
@07      EQU   07                                                       00197000
@08      EQU   08                                                       00198000
@09      EQU   09                                                       00199000
@10      EQU   10                                                       00200000
@11      EQU   11                                                       00201000
@12      EQU   12                                                       00202000
@13      EQU   13                                                       00203000
@14      EQU   14                                                       00204000
@15      EQU   15                                                       00205000
R9       EQU   @09                                                      00206000
R0       EQU   @00                                                      00207000
R1       EQU   @01                                                      00208000
R2       EQU   @02                                                      00209000
R3       EQU   @03                                                      00210000
R4       EQU   @04                                                      00211000
R5       EQU   @05                                                      00212000
RA       EQU   @10                                                      00213000
RB       EQU   @11                                                      00214000
RD       EQU   @13                                                      00215000
RE       EQU   @14                                                      00216000
RF       EQU   @15                                                      00217000
RC       EQU   @12                                                      00218000
R6       EQU   @06                                                      00219000
R7       EQU   @07                                                      00220000
R8       EQU   @08                                                      00221000
CMD      EQU   0                                                        00282000
CMDT     EQU   CMD+4                                                    00283000
PSCB     EQU   0                                                        00284000
PSCBATR1 EQU   PSCB+16                                                  00285000
ECT      EQU   0                                                        00286000
ECTSWS   EQU   ECT+28                                                   00287000
ECTSWS2  EQU   ECT+40                                                   00288000
ECTSWS21 EQU   ECTSWS2                                                  00289000
UPT      EQU   0                                                        00290000
UPTSWS   EQU   UPT+12                                                   00291000
SA       EQU   0                                                        00292000
SA1      EQU   SA                                                       00293000
SAR      EQU   SA+12                                                    00294000
SAR1     EQU   SAR+12                                                   00295000
MYRPLB   EQU   0                                                        00396000
IKJEFF02 EQU   0                                                        00493000
IKJEFF18 EQU   0                                                        00494000
IKJEFF19 EQU   0                                                        00495000
IKJGETL  EQU   0                                                        00496000
IKJPARS  EQU   0                                                        00497000
IKJPTGT  EQU   0                                                        00498000
IKJPUTL  EQU   0                                                        00499000
IKJSCAN  EQU   0                                                        00500000
IKJSTCK  EQU   0                                                        00501000
I001C    EQU   0                                                        00502000
I008P    EQU   0                                                        00503000
I015F    EQU   0                                                        00504000
I015P    EQU   0                                                        00505000
I031F    EQU   0                                                        00506000
I031P    EQU   0                                                        00507000
I256C    EQU   0                                                        00508000
PZ2      EQU   0                                                        00509000
CPPL     EQU   ZZ2CPPL                                                  00521000
CPPLUPT  EQU   CPPL+4                                                   00522000
CPPLPSCB EQU   CPPL+8                                                   00523000
CPPLECT  EQU   CPPL+12                                                  00524000
@ENDDATA EQU   *                                                        00987000
         END   BLSRESPU                                         DSKC069 00988000
