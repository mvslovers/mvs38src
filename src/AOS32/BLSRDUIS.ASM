DUIS     TITLE 'BLSRDUIS--DUMP INITIALIZATION--STORAGE RECORD          *00001000
                        '                                               00002000
*/* CHANGE ACTIVITY -------------------------------------------------*/ 00003000
*/*   THIS MODULE WAS WRITTEN FOR @G57LPRW                           */ 00004000
*/*   THIS MODULE HAS BEEN CHANGED BY @ZA32642               @ZA32642*/ 00005000
*/*------------------------------------------------------------------*/ 00006000
BLSRDUIS CSECT ,                                                01S0002 00007000
@MAINENT DS    0H                                               01S0002 00008000
         USING *,@15                                            01S0002 00009000
         B     @PROLOG                                          01S0002 00010000
         DC    AL1(23)                                          DSKC159 00011000
         DC    C'BLSRDUIS 81141 UZ36195 '                       DSKC159 00012000
         DROP  @15                                                      00013000
@PROLOG  STM   @14,@12,12(@13)                                  01S0002 00014000
         BALR  @12,0                                            01S0002 00015000
@PSTART  DS    0H                                               01S0002 00016000
         USING @PSTART,@12                                      01S0002 00017000
         L     @00,@SIZDATD                                     01S0002 00018000
         BLSUALLS R,LV=(0)                                              00019000
         LR    @11,@01                                          01S0002 00020000
         USING @DATD,@11                                        01S0002 00021000
         ST    @13,@SA00001+4                                   01S0002 00022000
         LM    @00,@01,20(@13)                                  01S0002 00023000
         ST    @11,8(,@13)                                      01S0002 00024000
         LR    @13,@11                                          01S0002 00025000
         MVC   @PC00001(12),0(@01)                              01S0002 00026000
*   RETC=ZZZFLAGI;                  /* RETURN CODE                   */ 00027000
         SLR   @07,@07                                          DSKC159 00028000
*   IF HSDSASI=HSDSASIS THEN        /* SUMMARY DUMP RECORD           */ 00029000
*                                                               01S0156 00030000
         L     @06,@PC00001+4                                   DSKC159 00031000
         L     @10,ZZ2AZZ6P(,@09)                               DSKC159 00031010
         CLC   HSDSASI(2,@06),@CH00091                          DSKC159 00032000
         BNE   A000338                                          DSKC159 00033000
         L     @03,@PC00001+8                                   DSKC159 00033010
         L     @08,A000398                                      DSKC159 00033020
         L     @14,SMDLRDAT+4-SMDLR(,@03)                       DSKC159 00033030
         CR    @14,@08                                          DSKC159 00033040
         BE    A000338                                          DSKC159 00033050
         SLR   @02,@02                                          DSKC159 00033060
         CR    @14,@02                                          DSKC159 00033070
         BNE   A0000FA                                          DSKC159 00033080
         L     @14,HSDSP(,@06)                                  DSKC159 00033090
         CR    @14,@08                                          DSKC159 00033100
         BH    A000312                                          DSKC159 00033110
         C     @14,A000394                                      DSKC159 00033120
         BL    A000312                                          DSKC159 00033130
         LR    @04,@14                                          DSKC159 00033140
         SRDA  @04,32                                           DSKC159 00033150
         D     @04,A000390                                      DSKC159 00033160
         CR    @04,@02                                          DSKC159 00033170
         BNE   A000312                                          DSKC159 00033180
         TM    ZZ2AFC(@09),B'10000000'                          DSKC159 00033190
         BE    A0000E4                                          DSKC159 00033200
         ST    @09,@AL00001                                     DSKC159 00033210
         LA    @02,A000388                                      DSKC159 00033220
         ST    @02,@AL00001+4                                   DSKC159 00033230
         L     @08,ZZ2DVTP(,@09)                                DSKC159 00033240
         LA    @01,@AL00001                                     DSKC159 00033250
         L     @15,DVTCN00P(,@08)                               DSKC159 00033260
         BALR  @14,@15                                          DSKC159 00033270
         CR    @07,@15                                          DSKC159 00033280
         BNL   A0000C0                                          DSKC159 00033290
         LR    @07,@15                                          DSKC159 00033300
A0000C0  CH    @07,A000368                                      DSKC159 00033310
         BNE   A0000DA                                          DSKC159 00033320
         SLR   @02,@02                                          DSKC159 00033330
         ST    @02,SMDLRPL-SMDLR(,@03)                          DSKC159 00033340
         MVC   SMDLRDAT+4-SMDLR(4,@03),A000398                  DSKC159 00033350
         SLR   @07,@07                                          DSKC159 00033360
         B     A000338                                          DSKC159 00033370
A0000DA  CH    @07,A00036A                                      DSKC159 00033380
         BH    A000302                                          DSKC159 00033390
         SLR   @07,@07                                          DSKC159 00033400
A0000E4  MVC   SMDLRDAT+8-SMDLR(2,@03),ZZ6DQA2+2(@10)           DSKC159 00033410
         L     @08,HSDSP(,@06)                                  DSKC159 00033420
         ST    @08,ZZ6DPRP(,@10)                                DSKC159 00033430
         ST    @08,SMDLRDAT+4-SMDLR(,@03)                       DSKC159 00033440
         B     A000110                                          DSKC159 00033450
A0000FA  L     @14,HSDSP(,@06)                                  DSKC159 00033460
         LH    @02,@CH00096                                     DSKC159 00033470
         AL    @02,SMDLRDAT+4-SMDLR(,@03)                       DSKC159 00033480
         CR    @14,@02                                          DSKC159 00033490
         BNE   A000312                                          DSKC159 00033500
         ST    @14,SMDLRDAT+4-SMDLR(,@03)                       DSKC159 00033510
*     /***************************************************************/ 00034000
*     /*                                                             */ 00035000
*     /* SUMMARY DUMP (SUMDUMP) RECORD                               */ 00036000
*     /*                                                             */ 00037000
*     /***************************************************************/ 00038000
*                                                               01S0157 00039000
*     DO;                           /* SUMMARY DUMP RECORD           */ 00040000
*       RAAU=RACO;                  /* INITIALIZE RECORD             */ 00041000
A000110  L     @05,ZZ2RASYP(,@09)                               DSKC159 00042000
         SLR   @08,@08                                          DSKC159 00042010
         MVC   RAAU(148),RACO(@05)                              DSKC159 00043000
*       RAAUAS=ZZ6DQA;              /* ADDRESS SPACE                 */ 00044000
         MVC   RAAUAS(16),ZZ6DQA(@10)                           DSKC159 00046000
         ICM   @08,3,SMDLRDAT+8-SMDLR(@03)                      DSKC159 00046010
         ST    @08,RAAUAS2                                      DSKC159 00046020
*       RAAUUSE=1;                  /* ENTRIES IN USE                */ 00047000
         LA    @14,1                                            DSKC159 00048000
         STH   @14,RAAUUSE                                      DSKC159 00049000
*       RAAURNM(1)=1;               /* NUMBER OF RECORDS             */ 00050000
         STH   @14,RAAURNM                                      DSKC159 00051000
*       RAAURDA(1)=ZZ6DDA1;         /* DISK RECORD ADDRESS           */ 00052000
         MVC   RAAURDA(4),ZZ6DDA1(@10)                          DSKC159 00053000
*       IF EXCESSL^=0 THEN          /* SUMDUMP LOGICAL RECORD ACTIVE */ 00054000
*                                                               01S0163 00055000
*         /***********************************************************/ 00060000
*         /*                                                         */ 00061000
*         /* SUMDUMP LOGICAL RECORD ACTIVE                           */ 00062000
*         /*                                                         */ 00063000
*         /***********************************************************/ 00064000
*                                                               01S0164 00065000
*         DO;                       /* SUMDUMP LOGICAL RECORD ACTIVE */ 00066000
*           RAAURIA(1)=EXCESSP;     /* ->FIRST BYTE DESCRIBED        */ 00067000
*           RAAURLE(1)=MIN(EXCESSL,LENGTH(HSDSC));/* LENGTH OF DATA  */ 00070000
         SLR   @05,@05                                          DSKC159 00075000
         L     @08,SMDLRDAT-SMDLR(,@03)                         DSKC159 00076000
         CR    @08,@05                                          DSKC159 00077000
         LA    @04,HSDCPSA(,@06)                                DSKC159 00078000
         BE    A000178                                          DSKC159 00079000
         LA    @14,21                                           DSKC159 00080000
         SLR   @14,@08                                          DSKC159 00081000
         ST    @14,@AL00001+8                                   DSKC159 00082000
         ALR   @14,@03                                          DSKC159 00083000
         BCTR  @14,0                                            DSKC159 00084000
         LA    @02,20                                           DSKC159 00085000
         LR    @00,@02                                          DSKC159 00086000
         SL    @00,@AL00001+8                                   DSKC159 00087000
         LR    @01,@00                                          DSKC159 00088000
         EX    @01,A00037A                                      DSKC159 00089000
         ALR   @08,@04                                          DSKC159 00090000
         SLR   @08,@02                                          DSKC159 00091000
         LR    @04,@08                                          DSKC159 00092000
         ST    @05,SMDLRDAT-SMDLR(,@03)                         DSKC159 00093000
         B     A00018E                                          DSKC159 00094000
A000178  ICM   @02,15,SMDLRPL-SMDLR(@03)                        DSKC159 00095000
         BE    A000188                                          DSKC159 00096000
         SH    @04,A00036C                                      DSKC159 00097000
         B     A00018E                                          DSKC159 00098000
A000188  MVC   SMDLRHDR-SMDLR(20,@03),SMDLRHDR-SMDLR(@04)       DSKC159 00099000
A00018E  LR    @08,@06                                          DSKC159 00100000
         AH    @08,@CH00469                                     DSKC159 00101000
         LR    @14,@04                                          DSKC159 00102000
         ST    @14,@AL00001+12                                  DSKC159 00103000
         B     A0002E8                                          DSKC159 00104000
A00019E  L     @04,@AL00001+12                                  DSKC159 00105000
         LA    @04,SMDLRDAT-SMDLR(,@04)                         DSKC159 00106000
         LR    @05,@04                                          DSKC159 00107000
         SLR   @05,@06                                          DSKC159 00108000
         ST    @05,RAAUROF                                      DSKC159 00109000
         L     @14,SMDLRPL-SMDLR(,@03)                          DSKC159 00110000
         ALR   @04,@14                                          DSKC159 00111000
         CLC   SMDLRID-SMDLR(2,@03),@CH01134                    DSKC159 00112000
         BE    A0002E2                                          DSKC159 00113000
         L     @05,SMDLRLEN-SMDLR(,@03)                         DSKC159 00114000
         L     @02,A000398                                      DSKC159 00115000
         CLR   @05,@02                                          DSKC159 00116000
         BH    A000312                                          DSKC159 00117000
         ST    @14,@AL00001+16                                  DSKC159 00118000
         CLR   @14,@02                                          DSKC159 00119000
         BH    A000312                                          DSKC159 00120000
         L     @05,SMDLRADR-SMDLR(,@03)                         DSKC159 00121000
         LR    @02,@05                                          DSKC159 00122000
         ALR   @02,@14                                          DSKC159 00123000
         ST    @02,@AL00001+16                                  DSKC159 00124000
         CL    @05,A00039C                                      DSKC159 00125000
         BNL   A000312                                          DSKC159 00126000
         CL    @02,A0003A0                                      DSKC159 00127000
         BNL   A000312                                          DSKC159 00128000
         ST    @05,RAAURIA                                      DSKC159 00129000
         ST    @14,RAAURLE                                      DSKC159 00130000
         L     @05,@AL00001+16                                  DSKC159 00131000
         SL    @05,A00039C                                      DSKC159 00132000
         SLR   @14,@14                                          DSKC159 00133000
         CR    @05,@14                                          DSKC159 00134000
         BNH   A000230                                          DSKC159 00135000
         LR    @02,@04                                          DSKC159 00136000
         SLR   @02,@05                                          DSKC159 00137000
         CR    @02,@08                                          DSKC159 00138000
         BH    A000230                                          DSKC159 00139000
         L     @02,RAAURLE                                      DSKC159 00140000
         SLR   @02,@05                                          DSKC159 00141000
         ST    @02,RAAURLE                                      DSKC159 00142000
         AL    @02,@AL00001+12                                  DSKC159 00143000
         LR    @04,@02                                          DSKC159 00144000
         ST    @05,SMDLRPL-SMDLR(,@03)                          DSKC159 00145000
         ST    @14,SMDLRADR-SMDLR(,@03)                         DSKC159 00146000
         B     @RF00182                                         DSKC159 00147000
A000230  CR    @04,@08                                          DSKC159 00148000
         BNH   A000254                                          DSKC159 00149000
         LR    @05,@04                                          DSKC159 00150000
         SLR   @05,@08                                          DSKC159 00151000
         ST    @05,SMDLRPL-SMDLR(,@03)                          DSKC159 00152000
         LCR   @05,@05                                          DSKC159 00153000
         AL    @05,RAAURLE                                      DSKC159 00154000
         ST    @05,RAAURLE                                      DSKC159 00155000
         AL    @05,RAAURIA                                      DSKC159 00156000
         ST    @05,SMDLRADR-SMDLR(,@03)                         DSKC159 00157000
         B     @RF00182                                         DSKC159 00158000
A000254  CLC   SMDLRID-SMDLR(2,@03),A000372                     DSKC159 00159000
         BNE   A000278                                          DSKC159 00160000
         L     @14,@AL00001+12                                  DSKC159 00161000
         SLR   @05,@05                                          DSKC159 00161010
         ICM   @05,3,SMDLRDAT-SMDLR(@14)                        DSKC159 00161020
         CL    @05,A00038C                                      DSKC159 00161030
         BNE   A000274                                          DSKC159 00161040
         L     @05,ZZ6DQA2(,@10)                                DSKC159 00161050
A000274  ST    @05,RAAUAS2                                      DSKC159 00161060
A000278  CR    @04,@08                                          DSKC159 00161070
         BNE   A000288                                          DSKC159 00161080
         SLR   @14,@14                                          DSKC159 00161090
         ST    @14,SMDLRPL-SMDLR(,@03)                          DSKC159 00161100
         B     @RF00182                                         DSKC159 00161110
A000288  LR    @05,@08                                          DSKC159 00161120
         SLR   @05,@04                                          DSKC159 00161130
         LA    @14,20                                           DSKC159 00161140
         CLR   @05,@14                                          DSKC159 00161150
         BNL   A0002AA                                          DSKC159 00161160
         LR    @02,@05                                          DSKC159 00161170
         BCTR  @02,0                                            DSKC159 00161180
         EX    @02,A000380                                      DSKC159 00161190
         SLR   @14,@05                                          DSKC159 00161200
         ST    @14,SMDLRDAT-SMDLR(,@03)                         DSKC159 00161210
         LR    @04,@08                                          DSKC159 00161220
         B     @RF00182                                         DSKC159 00161230
A0002AA  MVC   SMDLRHDR-SMDLR(20,@03),SMDLRHDR-SMDLR(@04)       DSKC159 00161240
*                                                               01S0188 00162000
@RF00182 ICM   @05,15,RAAURLE                                   DSKC159 00163000
         BZ    A0002E2                                          DSKC159 00164000
*           /*********************************************************/ 00165000
*           /*                                                       */ 00166000
*           /* STORAGE DESCRIBED                                     */ 00167000
*           /*                                                       */ 00168000
*           /*********************************************************/ 00169000
*                                                               01S0189 00170000
*           DO;                     /* STORAGE DESCRIBED             */ 00171000
*             CALL BLSRRAAR(ZZ2,RAAU);/* ADD TO STORAGE DESCRIPTION  */ 00172000
         ST    @09,@AL00001                                     DSKC159 00173000
         LA    @14,RAAU                                         01S0190 00174000
         ST    @14,@AL00001+4                                   01S0190 00175000
         L     @02,ZZ2RVTP(,@09)                                DSKC159 00176000
         LA    @01,@AL00001                                     DSKC159 00177000
         L     @15,RVTRAARP(,@02)                               DSKC159 00178000
         BALR  @14,@15                                          01S0190 00179000
*             RETC=RF;              /* RETURN CODE                   */ 00180000
         CR    @07,@15                                          DSKC159 00181000
         BNL   A0002DA                                          DSKC159 00182000
         LR    @07,@15                                          DSKC159 00183000
A0002DA  CH    @07,A00036A                                      DSKC159 00184000
         BH    A000338                                          DSKC159 00185000
A0002E2  LR    @14,@04                                          DSKC159 00186000
         ST    @14,@AL00001+12                                  DSKC159 00186010
A0002E8  CR    @04,@08                                          DSKC159 00187000
         BNL   @DC00177                                         01S0193 00188000
         CLC   SMDLRID-SMDLR(2,@03),@CH01138                    DSKC159 00189000
         BNE   A00019E                                          DSKC159 00190000
@DC00177 DS    0H                                               01S0194 00193000
         MVC   SMDLRDAT+8-SMDLR(2,@03),RAAUAS2+2                DSKC159 00193010
         B     A000338                                          DSKC159 00193020
*     END;                          /* SUMMARY DUMP RECORD           */ 00194000
*   ELSE                            /* NOT A SUMMARY DUMP RECORD     */ 00195000
*     IF HSDSASI=HSDSASIR THEN      /* ABSOLUTE STORAGE RECORD       */ 00196000
A000302  SLR   @02,@02                                          DSKC159 00197000
         ST    @02,SMDLRPL-SMDLR(,@03)                          DSKC159 00198000
         MVC   SMDLRDAT+4-SMDLR(4,@03),A000398                  DSKC159 00199000
         B     A000338                                          DSKC159 00200000
*       ZZ6DFAB='1'B;               /* ABSOLUTE STORAGE AVAILABLE    */ 00201000
A000312  ST    @09,@AL00001                                     DSKC159 00202000
         LA    @08,A0003F4                                      DSKC159 00203000
*EXIT:                              /* COMMON EXIT PATH              */ 00204000
*   RETURN CODE(RETC);                                          01S0197 00205000
*                                                               01S0197 00206000
@RF00195 DS    0H                                               01S0197 00207000
@RC00156 DS    0H                                               01S0197 00208000
         ST    @08,@AL00001+4                                   DSKC159 00209000
         L     @15,ZZ2TRMVP(,@09)                               DSKC159 00210000
         LA    @01,@AL00001                                     DSKC159 00211000
         BALR  @14,@15                                          DSKC159 00212000
         SLR   @02,@02                                          DSKC159 00213000
         ST    @02,SMDLRPL-SMDLR(,@03)                          DSKC159 00214000
         MVC   SMDLRDAT+4-SMDLR(4,@03),A000398                  DSKC159 00215000
         LA    @07,8                                            DSKC159 00216000
A000338  ICM   @08,3,HSDSASI(@06)                               DSKC159 00216010
         BNE   @EL00001                                         DSKC159 00216020
         OI    ZZ6DFAB(@10),B'00010000'                         DSKC159 00216030
*/*BLSRPEND--DEBUGGING MODULE*/                                 01S0198 00217000
*                                                               01S0198 00218000
*/*BLSUPEND--MVS IPCS MODULE*/                                  01S0198 00219000
*                                                               01S0198 00220000
*                                                               01S0198 00221000
*                                                               01S0198 00222000
*    DECLARE /* COMMON VARIABLES */                             01S0198 00223000
*      I256C CHAR(256) BASED,                                   01S0198 00224000
*      I031F FIXED(31) BASED,                                   01S0198 00225000
*      I031P PTR(31)   BASED,                                   01S0198 00226000
*      I015F FIXED(15) BASED,                                   01S0198 00227000
*      I015P PTR(15)   BASED,                                   01S0198 00228000
*      I008P PTR(8)    BASED,                                   01S0198 00229000
*      I001C CHAR(1)   BASED;                                   01S0198 00230000
*    GENERATE NODEFS NOREFS DATA;                               01S0199 00231000
*   END BLSRDUIS /*BLRPEND(BLSRDUIS) */                         01S0200 00232000
*/* THE FOLLOWING INCLUDE STATEMENTS WERE FOUND IN THIS PROGRAM.      * 00233000
*/*%INCLUDE SYSLIB  (BLSRZZZ )                                        * 00234000
*/*%INCLUDE SYSLIB  (BLSUZZZ )                                        * 00235000
*/*%INCLUDE SYSLIB  (BLRFULL )                                        * 00236000
*/*%INCLUDE SYSLIB  (IKJCPPL )                                        * 00237000
*/*%INCLUDE SYSLIB  (IKJPSCB )                                        * 00238000
*/*%INCLUDE SYSLIB  (IKJECT  )                                        * 00239000
*/*%INCLUDE SYSLIB  (IKJUPT  )                                        * 00240000
*/*%INCLUDE SYSLIB  (BLSUSERV)                                        * 00241000
*/*%INCLUDE SYSLIB  (BLRSERV )                                        * 00242000
*/*%INCLUDE SYSLIB  (BLRSERVD)                                        * 00243000
*/*%INCLUDE SYSLIB  (BLSRSERV)                                        * 00244000
*/*%INCLUDE SYSLIB  (BLSRHSD )                                        * 00245000
*/*%INCLUDE SYSLIB  (IHASMDLR)                                        * 00246000
*;                                                              01S0200 00247000
@EL00001 L     @13,4(,@13)                                      01S0200 00248000
@EF00001 L     @00,@SIZDATD                                     01S0200 00249000
         LR    @01,@11                                          01S0200 00250000
         BLSUFRES R,LV=(0),A=(1)                                        00251000
         LR    @15,@07                                          DSKC159 00251010
         L     @14,12(,@13)                                     DSKC159 00251020
@ER00001 LM    @00,@12,20(@13)                                  DSKC159 00252000
         BR    @14                                              01S0200 00253000
@DATA    DS    0H                                                       00254000
A000368  DC    H'4'                                             DSKC159 00254010
A00036A  DC    H'8'                                             DSKC159 00254020
A00036C  DC    H'20'                                            DSKC159 00254030
@CH01138 DC    H'53'                                                    00255000
@CH01134 DC    H'59'                                                    00256000
A000372  DC    H'60'                                            DSKC159 00256010
@CH00096 DC    H'4096'                                                  00257000
@CH00469 DC    H'4104'                                                  00258000
@CH00091 DC    AL2(65530)                                               00259000
A00037A  MVC   0(,@14),HSDCPSA(@06)                             DSKC159 00265010
A000380  MVC   SMDLRHDR-SMDLR(0,@03),SMDLRHDR-SMDLR(@04)        DSKC159 00265020
         DC    X'195F'                       !!! SOURCE COMPARE FIX !!! 00266000
         DC    0F'0'                                            DSKC159 00266000
A000388  DC    X'000046F0'                                      DSKC159 00267030
A00038C  DC    X'0000FFFF'                                      DSKC159 00267040
A000390  DC    X'00010000'                                      DSKC159 00267050
A000394  DC    X'00020000'                                      DSKC159 00267060
A000398  DC    X'00FFFFFF'                                      DSKC159 00267070
A00039C  DC    X'01000000'                                      DSKC159 00267080
A0003A0  DC    X'01001000'                                      DSKC159 00267090
         DC    0F'0'                                            DSKC159 00466000
@SIZDATD DC    AL1(0)                                                   00467000
         DC    AL3(@ENDDATD-@DATD)                                      00468000
         DC    X'00000000'                                      DSKC159 00468010
         DC    X'00001000'                                      DSKC159 00468020
         DC    X'0000D400'                                      DSKC159 00468030
         DC    CL32'PSA'                                        DSKC159 00468040
         DC    F'0'                                             DSKC159 00468050
         DC    F'0'                                             DSKC159 00468060
         DC    F'0'                                             DSKC159 00468070
         DC    F'0'                                             DSKC159 00468080
         DC    C'A '                                            DSKC159 00468090
         DC    H'0'                                             DSKC159 00468100
         DC    F'0'                                             DSKC159 00468110
         DC    F'0'                                             DSKC159 00468120
         DC    F'0'                                             DSKC159 00468130
A0003F4  DC    AL2(56,0)                                        DSKC159 00468140
         DC    C'BLS18060I INVALID DATA IN SUMMARY '            DSKC159 00468150
         DC    C'DUMP HEADER RECORD'                            DSKC159 00468160
         DC    0F'0'                                            DSKC159 00469000
SMDWSAC  DC    AL2(17)                                                  00481000
         DC    AL2(18)                                                  00482000
         DC    AL2(19)                                                  00483000
         DC    AL2(20)                                                  00484000
         DC    AL2(21)                                                  00485000
         DC    AL2(22)                                                  00486000
         DC    AL2(23)                                                  00487000
         DC    AL2(24)                                                  00488000
         DC    AL2(25)                                                  00489000
         DC    AL2(26)                                                  00490000
         DC    AL2(27)                                                  00491000
         DC    AL2(28)                                                  00492000
         DC    AL2(29)                                                  00493000
         DC    AL2(30)                                                  00494000
         DC    AL2(54)                                                  00495000
         DC    AL2(55)                                                  00496000
         DC    AL2(6)                                           DSKC159 00496010
         DC    AL2(7)                                           DSKC159 00496020
         DC    AL2(8)                                           DSKC159 00496030
         DC    AL2(9)                                           DSKC159 00496040
         DC    AL2(10)                                          DSKC159 00496050
         DC    AL2(11)                                          DSKC159 00496060
         DC    AL2(12)                                          DSKC159 00496070
         DC    AL2(13)                                          DSKC159 00496080
         DC    AL2(14)                                          DSKC159 00496090
         DC    AL2(15)                                          DSKC159 00496100
         DC    AL2(16)                                          DSKC159 00496110
SMDWSAL  DC    AL2(31)                                                  00497000
         DC    AL2(32)                                                  00498000
         DC    AL2(33)                                                  00499000
         DC    AL2(34)                                                  00500000
         DC    AL2(35)                                                  00501000
         DC    AL2(36)                                                  00502000
         DC    AL2(37)                                                  00503000
         DC    AL2(38)                                                  00504000
         DC    AL2(39)                                                  00505000
         DC    AL2(40)                                                  00506000
         DC    AL2(41)                                                  00507000
         DC    AL2(42)                                                  00508000
         DC    AL2(43)                                                  00509000
         DC    AL2(44)                                                  00510000
         DC    AL2(45)                                                  00511000
         SPACE 2                                                        00513000
*********************************************************************** 00514000
* THE FOLLOWING AREA, BLRPATCH, IS RESERVED FOR PATCH APPLICATION     * 00515000
* TO OBTAIN PATCH ROOM IN THE @DATD AUTOMATIC STORAGE AREA, MODIFY    * 00516000
* CONSTANT @SIZDATD TO REFLECT THE DESIRED @DATD SIZE                 * 00517000
*********************************************************************** 00518000
         SPACE                                                          00519000
         DC    0D'0'                                            DSKC159 00522000
         DC    C'ZAPAREA 81141   '                              DSKC159 00523000
         DC    C'BLSRDUIS UZ36195'                              DSKC159 00523010
         DC    C'BLSRDUIS UZ36195'                              DSKC159 00523020
         DC    C'BLSRDUIS UZ36195'                              DSKC159 00523030
         DC    C'BLSRDUIS UZ36195'                              DSKC159 00523040
@DATD    DSECT                                                          00526000
@SA00001 DS    18F                                                      00526010
@PC00001 DS    3F                                                       00526020
@AL00001 DS    5A                                                       00526030
         DS    0F                                                       00526860
RAAU     DS    CL148                                                    00526870
         ORG   RAAU                                                     00526880
RAAURID  DS    CL2                                                      00526890
         DS    BL6                                                      00526900
RAAURDX  DS    FL4                                                      00526910
RAAUAS   DS    CL16                                                     00526920
         ORG   RAAUAS                                                   00526930
RAAUAS0  DS    0C                                                       00526940
RAAUAST  DS    CL2                                                      00526950
         DS    BL2                                                      00526960
RAAUAS1  DS    FL4                                                      00526970
RAAUAS2  DS    FL4                                                      00526980
         DS    BL4                                                      00526990
RAAUAS9  DS    0C                                                       00527000
         ORG   RAAU+28                                                  00527010
RAAUFAD  DS    AL4                                                      00527020
RAAUELK  DS    0C                                                       00527030
         DS    BL16                                                     00527040
RAAUDIM  DS    FL2                                                      00527050
RAAUUSE  DS    FL2                                                      00527060
RAAUR    DS    CL32                                                     00527070
         ORG   RAAUR+0                                                  00527080
RAAURIA  DS    AL4                                                      00527090
RAAURLE  DS    FL4                                                      00527100
RAAURNM  DS    FL2                                                      00527110
RAAURF   DS    BL2                                                      00527120
         ORG   RAAURF+0                                                 00527130
RAAURFU  DS    BL1                                                      00527140
RAAURFP  EQU   RAAURF+0                                                 00527150
RAAURFR  EQU   RAAURF+0                                                 00527160
         ORG   RAAUR+12                                                 00527180
RAAURDA  DS    FL4                                                      00527190
RAAUROF  DS    FL4                                                      00527200
         DS    BL12                                                     00527210
         ORG   RAAU+148                                                 00527220
RAAU999  DS    0C                                                       00527230
         ORG   RAAU+148                                                 00527240
         DS    0D                                                       00527250
SAAU     DS    CL3072                                                   00527260
         ORG   SAAU                                                     00527270
SAAURID  DS    CL2                                                      00527280
         DS    BL6                                                      00527290
SAAURDX  DS    FL4                                                      00527300
SAAUAS   DS    CL16                                                     00527310
         ORG   SAAUAS                                                   00527320
SAAUAS0  DS    0C                                                       00527330
SAAUAST  DS    CL2                                                      00527340
         DS    BL2                                                      00527350
SAAUAS1  DS    FL4                                                      00527360
SAAUAS2  DS    FL4                                                      00527370
         DS    BL4                                                      00527380
SAAUAS9  DS    0C                                                       00527390
         ORG   SAAU+28                                                  00527400
SAAULAD  DS    AL4                                                      00527410
SAAUDT   DS    CL34                                                     00527420
         ORG   SAAUDT                                                   00527430
SAAUDT0  DS    0C                                                       00527440
SAAUDTY  DS    CL1                                                      00527450
         DS    BL1                                                      00527460
SAAUDTD  DS    CL31                                                     00527470
SAAUDTE  DS    CL1                                                      00527480
SAAUDT9  DS    0C                                                       00527490
         ORG   SAAU+66                                                  00527500
SAAUELK  DS    0C                                                       00527510
         DS    BL2                                                      00527520
SAAUF    DS    CL60                                                     00527530
         ORG   SAAUF                                                    00527540
SAAUF00  DS    0C                                                       00527550
SAAUFOF  DS    FL4                                                      00527560
SAAUFLE  DS    FL4                                                      00527570
SAAUFOB  DS    FL1                                                      00527580
SAAUFLB  DS    FL1                                                      00527590
SAAUFT   DS    CL34                                                     00527600
         ORG   SAAUFT                                                   00527610
SAAUFT0  DS    0C                                                       00527620
SAAUFTY  DS    CL1                                                      00527630
         DS    BL1                                                      00527640
SAAUFTD  DS    CL31                                                     00527650
SAAUFTE  DS    CL1                                                      00527660
SAAUFT9  DS    0C                                                       00527670
         ORG   SAAUF+44                                                 00527680
SAAUFIM  DS    FL4                                                      00527690
SAAUFIL  DS    FL4                                                      00527700
SAAUFF   DS    BL4                                                      00527710
         ORG   SAAUFF                                                   00527720
SAAUFFA  DS    BL1                                                      00527730
         ORG   SAAUF+56                                                 00527750
         DS    BL4                                                      00527760
SAAUF99  DS    0C                                                       00527770
         ORG   SAAU+128                                                 00527780
SAAUSF   DS    BL8                                                      00527790
         ORG   SAAUSF                                                   00527800
SAAUSF1  DS    BL1                                                      00527810
SAAUSF9  EQU   SAAUSF+0                                                 00527820
SAAUSFI  EQU   SAAUSF+0                                                 00527830
SAAUSFS  EQU   SAAUSF+0                                                 00527840
         ORG   SAAU+136                                                 00527860
SAAUGMT  DS    BL8                                                      00527870
SAAUPGV  DS    CL8                                                      00527880
SAAUSRC  DS    FL1                                                      00527890
         DS    101BL1                                                   00527900
SAAUC    DS    CL2818                                                   00527910
         ORG   SAAUC                                                    00527920
SAAUCL   DS    FL2                                                      00527930
SAAUCT   DS    CL2816                                                   00527940
         ORG   SAAUCT                                                   00527950
SAAUCT1  DS    CL2816                                                   00527960
         ORG   SAAU+3072                                                00527970
SAAU999  DS    0C                                                       00527980
         ORG   SAAU+3072                                                00527990
         DS    0D                                                       00532000
         ORG   *+1-(*-@DATD)/(*-@DATD) INSURE DSECT DATA                00534000
@ENDDATD EQU   *                                                        00535000
BLSRDUIS CSECT                                                          00536000
         BLSBVT  ,                                              DSKC159 00536010
         BLSESCO ,                                              DSKC159 00536020
         BLSRVT  ,                                              DSKC159 00536030
         BLSZZ1  ,                                              DSKC159 00536040
         BLSZZ2  ,                                              DSKC159 00536050
         BLSZZ6  ,                                              DSKC159 00536060
         BLSDVT  ,                                              DSKC159 00536070
         BLSHSD  ,                                              DSKC159 00536080
         IHASMDLR ,                                             DSKC159 00536090
@00      EQU   00                      EQUATES FOR REGISTERS 0-15       00537000
@01      EQU   01                                                       00538000
@02      EQU   02                                                       00539000
@03      EQU   03                                                       00540000
@04      EQU   04                                                       00541000
@05      EQU   05                                                       00542000
@06      EQU   06                                                       00543000
@07      EQU   07                                                       00544000
@08      EQU   08                                                       00545000
@09      EQU   09                                                       00546000
@10      EQU   10                                                       00547000
@11      EQU   11                                                       00548000
@12      EQU   12                                                       00549000
@13      EQU   13                                                       00550000
@14      EQU   14                                                       00551000
@15      EQU   15                                                       00552000
RETC     EQU   @04                                                      00553000
SMDLRPTR EQU   @03                                                      00554000
EORPTR   EQU   @05                                                      00555000
R9       EQU   @09                                                      00556000
R0       EQU   @00                                                      00557000
R1       EQU   @01                                                      00558000
R2       EQU   @02                                                      00559000
R3       EQU   @03                                                      00560000
R4       EQU   @04                                                      00561000
R5       EQU   @05                                                      00562000
RB       EQU   @11                                                      00563000
RD       EQU   @13                                                      00564000
RE       EQU   @14                                                      00565000
RF       EQU   @15                                                      00566000
RA       EQU   @10                                                      00567000
RC       EQU   @12                                                      00568000
R6       EQU   @06                                                      00569000
R7       EQU   @07                                                      00570000
R8       EQU   @08                                                      00571000
CMD      EQU   0                                                        00634000
CMDT     EQU   CMD+4                                                    00635000
PSCB     EQU   0                                                        00636000
PSCBATR1 EQU   PSCB+16                                                  00637000
ECT      EQU   0                                                        00638000
ECTSWS   EQU   ECT+28                                                   00639000
ECTSWS2  EQU   ECT+40                                                   00640000
ECTSWS21 EQU   ECTSWS2                                                  00641000
UPT      EQU   0                                                        00642000
UPTSWS   EQU   UPT+12                                                   00643000
SA       EQU   0                                                        00644000
SA1      EQU   SA                                                       00645000
SAR      EQU   SA+12                                                    00646000
SAR1     EQU   SAR+12                                                   00647000
RACO     EQU   0                                                        00765000
RACOAS   EQU   RACO+12                                                  00766000
RACOR    EQU   RACO+52                                                  00767000
RACORF   EQU   RACOR+10                                                 00768000
IKJEFF02 EQU   0                                                        00867000
IKJEFF18 EQU   0                                                        00868000
IKJEFF19 EQU   0                                                        00869000
IKJGETL  EQU   0                                                        00870000
IKJPARS  EQU   0                                                        00871000
IKJPTGT  EQU   0                                                        00872000
IKJPUTL  EQU   0                                                        00873000
IKJSCAN  EQU   0                                                        00874000
IKJSTCK  EQU   0                                                        00875000
I001C    EQU   0                                                        00876000
I008P    EQU   0                                                        00877000
I015F    EQU   0                                                        00878000
I015P    EQU   0                                                        00879000
I031F    EQU   0                                                        00880000
I031P    EQU   0                                                        00881000
I256C    EQU   0                                                        00882000
PZ2      EQU   0                                                        00883000
EXCESS   EQU   0                                                        00885000
EXCESSL  EQU   EXCESS                                                   00886000
EXCESSP  EQU   EXCESS+4                                                 00887000
CPPL     EQU   ZZ2CPPL                                                  00888000
CPPLUPT  EQU   CPPL+4                                                   00889000
CPPLPSCB EQU   CPPL+8                                                   00890000
CPPLECT  EQU   CPPL+12                                                  00891000
@ENDDATA EQU   *                                                        01463000
         END   BLSRDUIS                                         DSKC159 01464000
