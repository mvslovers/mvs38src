ESAR     TITLE 'BLSRESAR--ADD OR REPLACE AN EQUATE SYMBOL RECORD       *00001000
                        '                                               00002000
*/* CHANGE ACTIVITY -------------------------------------------------*/ 00003000
*/*   THIS MODULE WAS WRITTEN FOR @G57LPRW                           */ 00004000
*/*------------------------------------------------------------------*/ 00005000
BLSRESAR CSECT ,                                                01S0002 00006000
@MAINENT DS    0H                                               01S0002 00007000
         USING *,@15                                            01S0002 00008000
         B     @PROLOG                                          01S0002 00009000
         DC    AL1(23)                                          DSKC073 00010000
         DC    C'BLSRESAR 81066 UZ35265 '                       DSKC073 00011000
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
*   RA=ADDR(ESPA);                  /* ->ESBA (ALIAS FOR ESPA)       */ 00026000
         L     @10,@PC00001+4                                   DSKC073 00027000
*   ESBARDX=ZZ6DRDX;                /* DATA SET INDEX                */ 00028000
         L     @14,ZZ2AZZ6P(,@09)                               DSKC073 00029000
         LA    @01,@AL00001                                     DSKC073 00029010
         MVC   ESBARDX(4,@10),ZZ6DRDX(@14)                      DSKC073 00030000
*   CALL BLSRESCK(ZZ2,ESBA);        /* VALIDATE EQUATE SYMBOL RECORD */ 00031000
         ST    @09,@AL00001                                     DSKC073 00032000
         ST    @10,@AL00001+4                                   DSKC073 00033000
         L     @06,ZZ2RVTP(,@09)                                DSKC073 00034000
         LR    @13,@11                                          DSKC073 00034010
         L     @15,RVTESCKP(,@06)                               DSKC073 00035000
         BALR  @14,@15                                          01S0136 00037000
         LR    @07,@15                                          DSKC073 00037010
*   IF RF=ZZZFLAGI THEN             /* VALID EQUATE SYMBOL RECORD    */ 00038000
*                                                               01S0137 00039000
         LTR   @15,@15                                          DSKC073 00040000
         BNZ   A0001E6                                          DSKC073 00041000
*     /***************************************************************/ 00042000
*     /*                                                             */ 00043000
*     /* VALID EQUATE SYMBOL RECORD                                  */ 00044000
*     /*                                                             */ 00045000
*     /***************************************************************/ 00046000
*                                                               01S0138 00047000
*     DO;                           /* VALID EQUATE SYMBOL RECORD    */ 00048000
*       RESPECIFY                                               01S0139 00049000
*        (R2,                       /* KEY LENGTH                    */ 00050000
*         R3,                       /* ->ACB                         */ 00051000
*         R4,                       /* RECORD LENGTH                 */ 00052000
*         R5) RESTRICTED;           /* ->RPL                         */ 00053000
*       R2=ESBALKL;                 /* KEY LENGTH                    */ 00054000
         L     @06,ZZ2ZZ1P(,@09)                                DSKC073 00055000
*       R3=ZZ1ACBP;                 /* ->ACB                         */ 00056000
         LA    @02,59                                           DSKC073 00057000
         L     @03,ZZ1ACBP(,@06)                                DSKC073 00058000
*       R4=ESBALRL+ESBARL;          /* RECORD LENGTH                 */ 00059000
         LA    @04,182                                          DSKC073 00060000
         SLR   @06,@06                                          DSKC073 00061000
         ICM   @06,3,ESBARL(@10)                                DSKC073 00062000
         ALR   @04,@06                                          DSKC073 00063000
*       R5=ADDR(MYRPLA);            /* ->RPL                         */ 00064000
         LA    @05,MYRPLA                                       DSKC073 00065000
*       GENERATE SETS(GENPARM) CODE;                            01S0144 00066000
*---------------------------------------------------------------------* 00067000
*   CREATE AN RPL TO RETRIEVE ANY EXISTING RECORD FOR DELETION        * 00068000
*---------------------------------------------------------------------* 00069000
         GENCB BLK=RPL,WAREA=(@05),LENGTH=256,KEYLEN=(@02),     DSKC073*00070000
               ACB=(@03),AREA=(@10),ARG=(@10),AREALEN=(@04),    DSKC073*00071000
               RECLEN=(R4),                                     DSKC073*00071010
               OPTCD=(DIR,MVE,GEN,UPD),MF=(L,GENPARM,GENPARML)  DSKC073 00072000
*       RESPECIFY                                               01S0145 00073000
*        (R2,                       /* KEY LENGTH                    */ 00074000
*         R3,                       /* ->ACB                         */ 00075000
*         R4) UNRESTRICTED;         /* RECORD LENGTH                 */ 00076000
*       CALL BLSUVSCR(ZZ2,GENPARM); /* CREATE AN RPL                 */ 00077000
         ST    @09,@AL00001                                     DSKC073 00078000
         LA    @06,GENPARM                                      DSKC073 00079000
         ST    @06,@AL00001+4                                   DSKC073 00080000
         L     @08,ZZ2BVTP(,@09)                                DSKC073 00081000
         LA    @01,@AL00001                                     DSKC073 00082000
         L     @15,BVTVSCRP(,@08)                               DSKC073 00083000
         BALR  @14,@15                                          01S0146 00084000
*       IF RF=ZZZFLAGI THEN         /* RPL CREATED                   */ 00085000
         LTR   @15,@15                                          DSKC073 00086000
         BNZ   A000180                                          DSKC073 00087000
*         CALL BLSUVSAR(ZZ2,MYRPLB);/* ADD OR REPLACE THE RECORD     */ 00088000
         ST    @09,@AL00001                                     DSKC073 00089000
         ST    @05,@AL00001+4                                   DSKC073 00090000
         L     @04,ZZ2BVTP(,@09)                                DSKC073 00091000
         LA    @01,@AL00001                                     DSKC073 00092000
         L     @15,BVTVSARP(,@04)                               DSKC073 00093000
         BALR  @14,@15                                          01S0148 00094000
A000180  CR    @07,@15                                          DSKC073 00094010
         BNL   A000188                                          DSKC073 00094020
         LR    @07,@15                                          DSKC073 00094030
A000188  CLC   ESBASYM(31,@10),A000218                          DSKC073 00094040
         BNE   A0001E6                                          DSKC073 00094050
         L     @04,ZZ2AZZ6P(,@09)                               DSKC073 00094060
         L     @06,ESBALAD(,@10)                                DSKC073 00094070
         AL    @06,ESBADOF(,@10)                                DSKC073 00094080
         ST    @06,ZZ6DPRP(,@04)                                DSKC073 00094090
         L     @08,ESBADIM(,@10)                                DSKC073 00094100
         LA    @14,1                                            DSKC073 00094110
         CLR   @08,@14                                          DSKC073 00094120
         BNL   A0001B2                                          DSKC073 00094130
         LR    @08,@14                                          DSKC073 00094140
A0001B2  LR    @03,@08                                          DSKC073 00094150
         M     @02,ESBADLE(,@10)                                DSKC073 00094160
         ALR   @06,@03                                          DSKC073 00094170
         ST    @06,ZZ6DCAP(,@04)                                DSKC073 00094180
         MVC   ZZ2PGM(8,@09),A000210                            DSKC073 00094190
         ST    @09,@AL00001                                     DSKC073 00094200
         LA    @04,ZZ6D(,@04)                                   DSKC073 00094210
         ST    @04,@AL00001+4                                   DSKC073 00094220
         L     @06,ZZ2BVTP(,@09)                                DSKC073 00094230
         LA    @01,@AL00001                                     DSKC073 00094240
         L     @15,BVTPGMCP(,@06)                               DSKC073 00094250
         BALR  @14,@15                                          DSKC073 00094260
         CR    @07,@15                                          DSKC073 00094270
         BNL   A0001E6                                          DSKC073 00094280
*     END;                          /* VALID EQUATE SYMBOL RECORD    */ 00095000
@RF00147 DS    0H                                               01S0150 00096000
*   RETURN CODE(RF);                                            01S0150 00097000
*                                                               01S0150 00098000
@RF00137 LR    @07,@15                                          DSKC073 00099000
A0001E6  L     @13,4(,@13)                                      DSKC073 00100000
         L     @00,@SIZDATD                                     01S0150 00101000
         LR    @01,@11                                          01S0150 00102000
         BLSUFRES R,LV=(0),A=(1)                                        00103000
         LR    @15,@07                                          DSKC073 00104000
         L     @14,12(,@13)                                     01S0150 00105000
         LM    @00,@12,20(@13)                                  01S0150 00106000
         BR    @14                                              01S0150 00107000
*/*BLSRPEND--DEBUGGING MODULE                                        */ 00108000
*/*BLSUPEND--MVS IPCS MODULE                                         */ 00109000
*                                                               01S0151 00110000
*   DECLARE                         /* COMMON VARIABLES              */ 00111000
*     I256C CHAR(256) BASED,                                    01S0151 00112000
*     I031F FIXED(31) BASED,                                    01S0151 00113000
*     I031P PTR(31) BASED,                                      01S0151 00114000
*     I015F FIXED(15) BASED,                                    01S0151 00115000
*     I015P PTR(15) BASED,                                      01S0151 00116000
*     I008P PTR(8) BASED,                                       01S0151 00117000
*     I001C CHAR(1) BASED;                                      01S0151 00118000
*   GENERATE NODEFS NOREFS DATA;                                01S0152 00119000
*   END BLSRESAR                    /* BLRPEND(BLSRESAR)             */ 00120000
*                                                               01S0153 00121000
*/* THE FOLLOWING INCLUDE STATEMENTS WERE FOUND IN THIS PROGRAM.     */ 00122000
*/*%INCLUDE SYSLIB  (BLSRZZZ )                                       */ 00123000
*/*%INCLUDE SYSLIB  (BLSUZZZ )                                       */ 00124000
*/*%INCLUDE SYSLIB  (BLRFULL )                                       */ 00125000
*/*%INCLUDE SYSLIB  (IKJCPPL )                                       */ 00126000
*/*%INCLUDE SYSLIB  (IKJPSCB )                                       */ 00127000
*/*%INCLUDE SYSLIB  (IKJECT  )                                       */ 00128000
*/*%INCLUDE SYSLIB  (IKJUPT  )                                       */ 00129000
*/*%INCLUDE SYSLIB  (BLSUSERV)                                       */ 00130000
*/*%INCLUDE SYSLIB  (BLRSERV )                                       */ 00131000
*/*%INCLUDE SYSLIB  (BLRSERVD)                                       */ 00132000
*/*%INCLUDE SYSLIB  (BLSRSERV)                                       */ 00133000
*                                                               01S0153 00134000
*       ;                                                       01S0153 00135000
         DC    X'E0C4'                       !!! SOURCE COMPARE FIX !!! 00142000
@DATA    DS    0H                                                       00142000
@DATD    DSECT                                                          00143000
         DS    0F                                                       00144000
@SA00001 DS    18F                                                      00145000
@PC00001 DS    2F                                                       00146000
@AL00001 DS    2A                                                       00147000
BLSRESAR CSECT                                                          00148000
         DS    0F                                                       00149000
@DATD    DSECT                                                          00150000
         DS    0D                                                       00151000
MYRPLA   DS    CL256                                                    00152000
BLSRESAR CSECT                                                          00153000
         DS    0F                                                       00154000
@SIZDATD DC    AL1(0)                                                   00155000
         DC    AL3(@ENDDATD-@DATD)                                      00156000
A000210  DC    C'BLSRRDAR'                                      DSKC073 00156010
A000218  DC    CL31'PRIVATE'                                    DSKC073 00156020
         DS    0D                                                       00157000
@DATD    DSECT                                                          00158000
         SPACE 2                                                        00159000
*********************************************************************** 00160000
* THE FOLLOWING AREA, BLRPATCH, IS RESERVED FOR PATCH APPLICATION     * 00161000
* TO OBTAIN PATCH ROOM IN THE @DATD AUTOMATIC STORAGE AREA, MODIFY    * 00162000
* CONSTANT @SIZDATD TO REFLECT THE DESIRED @DATD SIZE                 * 00163000
*********************************************************************** 00164000
         SPACE                                                          00165000
BLSRESAR CSECT                                                          00166000
         ORG                                                            00167000
         DS    0D                                                       00168000
BLRPATCH DC    C'ZAPAREA 81066   '                              DSKC073 00169000
         DC    C'BLSRESAR UZ35265'                              DSKC073 00169010
         DC    C'BLSRESAR UZ35265'                              DSKC073 00169020
@DATD    DSECT                                                          00170000
         DS    0H                                                       00171000
@DATD    DSECT                                                          00172000
*---------------------------------------------------------------------* 00173000
*   RESERVE SPACE FOR A GENCB PARAMETER LIST                          * 00174000
*---------------------------------------------------------------------* 00175000
GENPARM  DS    (GENPARML)CL1           GENCB PARAMETER LIST             00176000
@DATD    DSECT                                                          00177000
         SPACE 2                                                        00178000
*********************************************************************** 00179000
* ALIGN END OF DATA ON A DOUBLEWORD BOUNDARY                          * 00180000
*********************************************************************** 00181000
         SPACE                                                          00182000
         DS    0D                                                       00183000
@DATD    DSECT                                                          00184000
         ORG   *+1-(*-@DATD)/(*-@DATD) INSURE DSECT DATA                00185000
@ENDDATD EQU   *                                                        00186000
BLSRESAR CSECT                                                          00187000
         BLSBVT  ,                                              DSKC073 00187010
         BLSESBA ,                                              DSKC073 00187020
         BLSESPA ,                                              DSKC073 00187030
         BLSRVT  ,                                              DSKC073 00187040
         BLSZZ1  ,                                              DSKC073 00187050
         BLSZZ2  ,                                              DSKC073 00187070
         BLSZZ6  ,                                              DSKC073 00187080
@00      EQU   00                      EQUATES FOR REGISTERS 0-15       00188000
@01      EQU   01                                                       00189000
@02      EQU   02                                                       00190000
@03      EQU   03                                                       00191000
@04      EQU   04                                                       00192000
@05      EQU   05                                                       00193000
@06      EQU   06                                                       00194000
@07      EQU   07                                                       00195000
@08      EQU   08                                                       00196000
@09      EQU   09                                                       00197000
@10      EQU   10                                                       00198000
@11      EQU   11                                                       00199000
@12      EQU   12                                                       00200000
@13      EQU   13                                                       00201000
@14      EQU   14                                                       00202000
@15      EQU   15                                                       00203000
R9       EQU   @09                                                      00204000
R0       EQU   @00                                                      00205000
R1       EQU   @01                                                      00206000
R2       EQU   @02                                                      00207000
R3       EQU   @03                                                      00208000
R4       EQU   @04                                                      00209000
R5       EQU   @05                                                      00210000
RA       EQU   @10                                                      00211000
RB       EQU   @11                                                      00212000
RD       EQU   @13                                                      00213000
RE       EQU   @14                                                      00214000
RF       EQU   @15                                                      00215000
RC       EQU   @12                                                      00216000
R6       EQU   @06                                                      00217000
R7       EQU   @07                                                      00218000
R8       EQU   @08                                                      00219000
CMD      EQU   0                                                        00280000
CMDT     EQU   CMD+4                                                    00281000
PSCB     EQU   0                                                        00282000
PSCBATR1 EQU   PSCB+16                                                  00283000
ECT      EQU   0                                                        00284000
ECTSWS   EQU   ECT+28                                                   00285000
ECTSWS2  EQU   ECT+40                                                   00286000
ECTSWS21 EQU   ECTSWS2                                                  00287000
UPT      EQU   0                                                        00288000
UPTSWS   EQU   UPT+12                                                   00289000
SA       EQU   0                                                        00290000
SA1      EQU   SA                                                       00291000
SAR      EQU   SA+12                                                    00292000
SAR1     EQU   SAR+12                                                   00293000
MYRPLB   EQU   0                                                        00406000
IKJEFF02 EQU   0                                                        00502000
IKJEFF18 EQU   0                                                        00503000
IKJEFF19 EQU   0                                                        00504000
IKJGETL  EQU   0                                                        00505000
IKJPARS  EQU   0                                                        00506000
IKJPTGT  EQU   0                                                        00507000
IKJPUTL  EQU   0                                                        00508000
IKJSCAN  EQU   0                                                        00509000
IKJSTCK  EQU   0                                                        00510000
I001C    EQU   0                                                        00511000
I008P    EQU   0                                                        00512000
I015F    EQU   0                                                        00513000
I015P    EQU   0                                                        00514000
I031F    EQU   0                                                        00515000
I031P    EQU   0                                                        00516000
I256C    EQU   0                                                        00517000
PZ2      EQU   0                                                        00518000
CPPL     EQU   ZZ2CPPL                                                  00529000
CPPLUPT  EQU   CPPL+4                                                   00530000
CPPLPSCB EQU   CPPL+8                                                   00531000
CPPLECT  EQU   CPPL+12                                                  00532000
@ENDDATA EQU   *                                                        01045000
         END   BLSRESAR                                         DSKC073 01046000
