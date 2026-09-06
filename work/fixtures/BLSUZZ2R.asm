ZZ2R     TITLE 'BLSUZZ2R--REFRESH TASK VARIABLE                        *00001000
                        '                                               00002000
*/* CHANGE ACTIVITY -------------------------------------------------*/ 00003000
*/*   THIS MODULE WAS WRITTEN FOR @G57LPRW                           */ 00004000
*/*------------------------------------------------------------------*/ 00005000
BLSUZZ2R CSECT ,                                                01S0002 00006000
@MAINENT DS    0H                                               01S0002 00007000
         USING *,@15                                            01S0002 00008000
         B     @PROLOG                                          01S0002 00009000
         DC    AL1(16)                                          01S0002 00010000
         DC    C'BLSUZZ2R  78.060'                              01S0002 00011000
         DROP  @15                                                      00012000
@PROLOG  STM   @14,@12,12(@13)                                  01S0002 00013000
         BALR  @12,0                                            01S0002 00014000
@PSTART  DS    0H                                               01S0002 00015000
         USING @PSTART,@12                                      01S0002 00016000
         STCK  ZZ2TOD(R1)                                               00017000
*   RE=ADDR(ZZ2A);                  /* ->MODAL DATA FOR TASK         */ 00018000
         LA    RE,ZZ2A(,R1)                                     01S0075 00019000
*   RF=LENGTH(ZZ2A);                /* LENGTH OF MODAL DATA          */ 00020000
         LA    RF,656                                           01S0076 00021000
*   R0=ADDR(ZZ1ZZ2P->ZZ2A);         /* ->MASTER MODAL DATA           */ 00022000
         L     @11,ZZ2ZZ1P(,R1)                                 01S0077 00023000
         L     @11,ZZ1ZZ2P(,@11)                                01S0077 00024000
         LA    R0,ZZ2A(,@11)                                    01S0077 00025000
*   R1=RF;                          /* LENGTH OF MODAL DATA          */ 00026000
         LR    R1,RF                                            01S0078 00027000
*   MVCL(RE,R0);                    /* COPY MODAL DATA               */ 00028000
         MVCL  RE,R0                                            01S0079 00029000
*   RETURN CODE(RF);                /* RF=0 SET BY MVCL              */ 00030000
         L     @14,12(,@13)                                     01S0080 00031000
         LM    @00,@12,20(@13)                                  01S0080 00032000
         BR    @14                                              01S0080 00033000
*/*BLSUPEND--MVS IPCS MODULE                                         */ 00034000
*                                                               01S0081 00035000
*   DECLARE                         /* COMMON VARIABLES              */ 00036000
*     I256C CHAR(256) BASED,                                    01S0081 00037000
*     I031F FIXED(31) BASED,                                    01S0081 00038000
*     I031P PTR(31) BASED,                                      01S0081 00039000
*     I015F FIXED(15) BASED,                                    01S0081 00040000
*     I015P PTR(15) BASED,                                      01S0081 00041000
*     I008P PTR(8) BASED,                                       01S0081 00042000
*     I001C CHAR(1) BASED;                                      01S0081 00043000
*   GENERATE NODEFS NOREFS DATA;                                01S0082 00044000
*   END BLSUZZ2R                    /* BLRPEND(BLSUZZ2R)             */ 00045000
*                                                               01S0083 00046000
*/* THE FOLLOWING INCLUDE STATEMENTS WERE FOUND IN THIS PROGRAM.     */ 00047000
*/*%INCLUDE SYSLIB  (BLSUZZZ )                                       */ 00048000
*/*%INCLUDE SYSLIB  (BLRFULL )                                       */ 00049000
*/*%INCLUDE SYSLIB  (IKJCPPL )                                       */ 00050000
*/*%INCLUDE SYSLIB  (IKJPSCB )                                       */ 00051000
*/*%INCLUDE SYSLIB  (IKJECT  )                                       */ 00052000
*/*%INCLUDE SYSLIB  (IKJUPT  )                                       */ 00053000
*/*%INCLUDE SYSLIB  (BLSUSERV)                                       */ 00054000
*/*%INCLUDE SYSLIB  (BLRSERV )                                       */ 00055000
*/*%INCLUDE SYSLIB  (BLRSERVD)                                       */ 00056000
*                                                               01S0083 00057000
*       ;                                                       01S0083 00058000
@EL00001 DS    0H                                               01S0083 00059000
@EF00001 DS    0H                                               01S0083 00060000
@ER00001 LM    @14,@12,12(@13)                                  01S0083 00061000
         BR    @14                                              01S0083 00062000
@DATA    DS    0H                                                       00063000
@DATD    DSECT                                                          00064000
         DS    0F                                                       00065000
BLSUZZ2R CSECT                                                          00066000
         DS    0F                                                       00067000
@DATD    DSECT                                                          00068000
         DS    0D                                                       00069000
BLSUZZ2R CSECT                                                          00070000
         NOPR  ((@ENDDATD-@DATD)*16)                                    00071000
         DS    0F                                                       00072000
@SIZDATD DC    AL1(0)                                                   00073000
         DC    AL3(@ENDDATD-@DATD)                                      00074000
         DS    0D                                                       00075000
@DATD    DSECT                                                          00076000
         SPACE 2                                                        00077000
*********************************************************************** 00078000
* THE FOLLOWING AREA, BLRPATCH, IS RESERVED FOR PATCH APPLICATION     * 00079000
*********************************************************************** 00080000
         SPACE                                                          00081000
BLSUZZ2R CSECT                                                          00082000
         ORG                                                            00083000
         DS    0D                                                       00084000
BLRPATCH DC    CL8'ZAPAREA',(((*-BLSUZZ2R+19)/20+7)/8)CL8'BLSUZZ2R'     00085000
@DATD    DSECT                                                          00086000
         SPACE 2                                                        00087000
*********************************************************************** 00088000
* ALIGN END OF DATA ON A DOUBLEWORD BOUNDARY                          * 00089000
*********************************************************************** 00090000
         SPACE                                                          00091000
         DS    0D                                                       00092000
@DATD    DSECT                                                          00093000
@ENDDATD EQU   *                                                        00094000
BLSUZZ2R CSECT                                                          00095000
@00      EQU   00                      EQUATES FOR REGISTERS 0-15       00096000
@01      EQU   01                                                       00097000
@02      EQU   02                                                       00098000
@03      EQU   03                                                       00099000
@04      EQU   04                                                       00100000
@05      EQU   05                                                       00101000
@06      EQU   06                                                       00102000
@07      EQU   07                                                       00103000
@08      EQU   08                                                       00104000
@09      EQU   09                                                       00105000
@10      EQU   10                                                       00106000
@11      EQU   11                                                       00107000
@12      EQU   12                                                       00108000
@13      EQU   13                                                       00109000
@14      EQU   14                                                       00110000
@15      EQU   15                                                       00111000
R1       EQU   @01                                                      00112000
R0       EQU   @00                                                      00113000
R2       EQU   @02                                                      00114000
R3       EQU   @03                                                      00115000
R4       EQU   @04                                                      00116000
R5       EQU   @05                                                      00117000
R9       EQU   @09                                                      00118000
RB       EQU   @11                                                      00119000
RD       EQU   @13                                                      00120000
RE       EQU   @14                                                      00121000
RF       EQU   @15                                                      00122000
RA       EQU   @10                                                      00123000
RC       EQU   @12                                                      00124000
R6       EQU   @06                                                      00125000
R7       EQU   @07                                                      00126000
R8       EQU   @08                                                      00127000
ZZ1      EQU   0                                                        00128000
ZZ1ZZ2P  EQU   ZZ1+36                                                   00129000
ZZ1ATTN  EQU   ZZ1+360                                                  00130000
ZZ1EVE   EQU   ZZ1ATTN+4                                                00131000
ZZ1F     EQU   ZZ1+368                                                  00132000
ZZ1N     EQU   ZZ1+1116                                                 00133000
ZZ2      EQU   0                                                        00134000
ZZ2AMD   EQU   ZZ2                                                      00135000
@NM00013 EQU   ZZ2AMD+7                                                 00136000
ZZ2PRT   EQU   ZZ2+138                                                  00137000
ZZ2PRTT  EQU   ZZ2PRT+4                                                 00138000
ZZ2PRTT1 EQU   ZZ2PRTT+1                                                00139000
ZZ2A     EQU   ZZ2+272                                                  00140000
ZZ2AF    EQU   ZZ2A+16                                                  00141000
ZZ2APID  EQU   ZZ2A+64                                                  00142000
ZZ2AD    EQU   ZZ2A+74                                                  00143000
ZZ2ADD   EQU   ZZ2AD                                                    00144000
ZZ2ADDT  EQU   ZZ2ADD+2                                                 00145000
ZZ2ADM   EQU   ZZ2AD+46                                                 00146000
ZZ2ADMT  EQU   ZZ2ADM+2                                                 00147000
ZZ2ADP   EQU   ZZ2AD+56                                                 00148000
ZZ2ADPT  EQU   ZZ2ADP+2                                                 00149000
ZZ2AQAS  EQU   ZZ2A+144                                                 00150000
ZZ2AQD   EQU   ZZ2A+160                                                 00151000
ZZ2AQDT  EQU   ZZ2AQD+10                                                00152000
ZZ2AQDF  EQU   ZZ2AQD+52                                                00153000
ZZ2STG   EQU   ZZ2+960                                                  00154000
ZZ2TOD   EQU   ZZ2+968                                                  00155000
ZZ2ALLOP EQU   ZZ2+992                                                  00156000
ZZ2FREEP EQU   ZZ2+996                                                  00157000
ZZ2FF19P EQU   ZZ2+1000                                                 00158000
ZZ2FRE1P EQU   ZZ2+1004                                                 00159000
ZZ2FF18P EQU   ZZ2+1008                                                 00160000
ZZ2DYNAP EQU   ZZ2+1012                                                 00161000
ZZ2ZZ2CP EQU   ZZ2+1016                                                 00162000
ZZ2ZZ2DP EQU   ZZ2+1020                                                 00163000
ZZ2STAIP EQU   ZZ2+1024                                                 00164000
ZZ2FF02P EQU   ZZ2+1028                                                 00165000
ZZ2GETLP EQU   ZZ2+1032                                                 00166000
ZZ2PARSP EQU   ZZ2+1036                                                 00167000
ZZ2PTGTP EQU   ZZ2+1040                                                 00168000
ZZ2PUTLP EQU   ZZ2+1044                                                 00169000
ZZ2SCANP EQU   ZZ2+1048                                                 00170000
ZZ2STCKP EQU   ZZ2+1052                                                 00171000
ZZ2TRMOP EQU   ZZ2+1064                                                 00172000
ZZ2TRMVP EQU   ZZ2+1068                                                 00173000
ZZ2PUTNP EQU   ZZ2+1084                                                 00174000
ZZ2TRMNP EQU   ZZ2+1088                                                 00175000
ZZ2ZZ1P  EQU   ZZ2+1264                                                 00176000
ZZ2BVTP  EQU   ZZ2+1280                                                 00177000
ZZ2CPPL  EQU   ZZ2+1292                                                 00178000
ZZ2CPPLC EQU   ZZ2CPPL                                                  00179000
ZZ2ITR   EQU   ZZ2+2840                                                 00180000
ZZ2ITRE  EQU   ZZ2ITR+16                                                00181000
ZZ2ITSE  EQU   ZZ2+2864                                                 00182000
ZZ2ES    EQU   ZZ2+2872                                                 00183000
ZZ2AMDX  EQU   ZZ2+7160                                                 00184000
ZZ2AXO   EQU   ZZ2+7934                                                 00185000
ZZ2AXOT  EQU   ZZ2AXO+2                                                 00186000
CMD      EQU   0                                                        00187000
CMDT     EQU   CMD+4                                                    00188000
PSCB     EQU   0                                                        00189000
PSCBATR1 EQU   PSCB+16                                                  00190000
ECT      EQU   0                                                        00191000
ECTSWS   EQU   ECT+28                                                   00192000
ECTSWS2  EQU   ECT+40                                                   00193000
ECTSWS21 EQU   ECTSWS2                                                  00194000
UPT      EQU   0                                                        00195000
UPTSWS   EQU   UPT+12                                                   00196000
SA       EQU   0                                                        00197000
SA1      EQU   SA                                                       00198000
SAR      EQU   SA+12                                                    00199000
BVT      EQU   0                                                        00200000
BVTPUTLP EQU   BVT+4                                                    00201000
BVTPUTOP EQU   BVT+12                                                   00202000
BVTPUTTP EQU   BVT+16                                                   00203000
BVTPUTVP EQU   BVT+20                                                   00204000
BVTPUTAP EQU   BVT+24                                                   00205000
BVTPRTTP EQU   BVT+28                                                   00206000
BVTPRTAP EQU   BVT+32                                                   00207000
BVTPUTDP EQU   BVT+36                                                   00208000
BVTMONP  EQU   BVT+40                                                   00209000
BVTMON2P EQU   BVT+44                                                   00210000
BVTVSARP EQU   BVT+48                                                   00211000
BVTVSENP EQU   BVT+64                                                   00212000
BVTVSERP EQU   BVT+68                                                   00213000
BVTVSGEP EQU   BVT+72                                                   00214000
BVTVSGUP EQU   BVT+76                                                   00215000
BVTVSPOP EQU   BVT+80                                                   00216000
BVTVSPUP EQU   BVT+84                                                   00217000
BVTMPKNP EQU   BVT+104                                                  00218000
BVTMONLP EQU   BVT+108                                                  00219000
BVTPUTCP EQU   BVT+132                                                  00220000
BVTMPK1P EQU   BVT+136                                                  00221000
BVTPGMRP EQU   BVT+144                                                  00222000
BVTMONAP EQU   BVT+148                                                  00223000
BVTBLDDP EQU   BVT+152                                                  00224000
BVTBLDLP EQU   BVT+156                                                  00225000
BVTPGMCP EQU   BVT+160                                                  00226000
BVTPGMDP EQU   BVT+164                                                  00227000
BVTPGMLP EQU   BVT+168                                                  00228000
BVTMONCP EQU   BVT+180                                                  00229000
BVTMONDP EQU   BVT+184                                                  00230000
BVTMONTP EQU   BVT+188                                                  00231000
BVTPARIP EQU   BVT+192                                                  00232000
BVTPARUP EQU   BVT+196                                                  00233000
BVTPRTNP EQU   BVT+204                                                  00234000
BVTVSCRP EQU   BVT+208                                                  00235000
BVTVSMRP EQU   BVT+212                                                  00236000
BVTMONXP EQU   BVT+216                                                  00237000
BVTTRMAP EQU   BVT+228                                                  00238000
BLSUALLO EQU   0                                                        00239000
BLSUBLDD EQU   0                                                        00240000
BLSUBLDL EQU   0                                                        00241000
BLSUDYNA EQU   0                                                        00242000
BLSUFREE EQU   0                                                        00243000
BLSUFRE1 EQU   0                                                        00244000
BLSUMON  EQU   0                                                        00245000
BLSUMONA EQU   0                                                        00246000
BLSUMONC EQU   0                                                        00247000
BLSUMOND EQU   0                                                        00248000
BLSUMONL EQU   0                                                        00249000
BLSUMONT EQU   0                                                        00250000
BLSUMONX EQU   0                                                        00251000
BLSUMON2 EQU   0                                                        00252000
BLSUMPKN EQU   0                                                        00253000
BLSUMPK1 EQU   0                                                        00254000
BLSUPARI EQU   0                                                        00255000
BLSUPARU EQU   0                                                        00256000
BLSUPGMC EQU   0                                                        00257000
BLSUPGMD EQU   0                                                        00258000
BLSUPGML EQU   0                                                        00259000
BLSUPGMR EQU   0                                                        00260000
BLSUPRTA EQU   0                                                        00261000
BLSUPRTN EQU   0                                                        00262000
BLSUPRTT EQU   0                                                        00263000
BLSUPUTA EQU   0                                                        00264000
BLSUPUTC EQU   0                                                        00265000
BLSUPUTD EQU   0                                                        00266000
BLSUPUTL EQU   0                                                        00267000
BLSUPUTN EQU   0                                                        00268000
BLSUPUTO EQU   0                                                        00269000
BLSUPUTT EQU   0                                                        00270000
BLSUPUTV EQU   0                                                        00271000
BLSUSTAI EQU   0                                                        00272000
BLSUTRMA EQU   0                                                        00273000
BLSUTRMN EQU   0                                                        00274000
BLSUTRMO EQU   0                                                        00275000
BLSUTRMV EQU   0                                                        00276000
BLSUVSAR EQU   0                                                        00277000
BLSUVSCR EQU   0                                                        00278000
BLSUVSEN EQU   0                                                        00279000
BLSUVSER EQU   0                                                        00280000
BLSUVSGE EQU   0                                                        00281000
BLSUVSGU EQU   0                                                        00282000
BLSUVSMR EQU   0                                                        00283000
BLSUVSPO EQU   0                                                        00284000
BLSUVSPU EQU   0                                                        00285000
BLSUZZ2C EQU   0                                                        00286000
BLSUZZ2D EQU   0                                                        00287000
IKJEFF02 EQU   0                                                        00288000
IKJEFF18 EQU   0                                                        00289000
IKJEFF19 EQU   0                                                        00290000
IKJGETL  EQU   0                                                        00291000
IKJPARS  EQU   0                                                        00292000
IKJPTGT  EQU   0                                                        00293000
IKJPUTL  EQU   0                                                        00294000
IKJSCAN  EQU   0                                                        00295000
IKJSTCK  EQU   0                                                        00296000
I001C    EQU   0                                                        00297000
I008P    EQU   0                                                        00298000
I015F    EQU   0                                                        00299000
I015P    EQU   0                                                        00300000
I031F    EQU   0                                                        00301000
I031P    EQU   0                                                        00302000
I256C    EQU   0                                                        00303000
CPPL     EQU   ZZ2CPPL                                                  00304000
CPPLUPT  EQU   CPPL+4                                                   00305000
CPPLPSCB EQU   CPPL+8                                                   00306000
CPPLECT  EQU   CPPL+12                                                  00307000
@ENDDATA EQU   *                                                        00626000
         END   BLSUZZ2R                                         DSKC515 00627000
