*********************************************************************** 00010000
*                                                                     * 00020000
* MODULE NAME : RDTRK                                                 * 00030000
* AUTHOR      : DAVE KREISS                                           * 00040000
* FUNCTIONS   : READ ALL DATA ON TRACK REQUESTED                      * 00050000
*                                                                     * 00060000
*********************************************************************** 00070000
*                                                                     * 00080000
*  INTERFACE  (SEE RDTRKRQ MACRO - READ TRACK REQUEST)                * 00090001
*      INPUT                                                          * 00100000
*        R1 = ADDRESS OF PARAMETER LIST                               * 00110000
*             WORD 1 = ADDRESS OF FUNCTION          OPEN  READ  CLOSE * 00120001
*                      =C'O' = OPEN                                   * 00130000
*                      =C'R' = READ                                   * 00140000
*                      =C'C' = CLOSE                                  * 00150000
*             WORD 2 = ADDRESS OF A 70K WORK AREA   OPEN  READ  CLOSE * 00160001
*                      SEE RDTRKWA MACRO                              * 00170001
*             WORD 3 = ADDRESS 4 BYTE CCHH          OPEN  READ        * 00180001
*             WORD 4 = ADDRESS 8 BYTE DDNAME        OPEN              * 00190001
*      OUTPUT                                                         * 00200000
*        R15 = RETURN CODE                                            * 00210000
*              0 = FUNCTION SUCCESSFUL                                * 00220000
*                  OPEN                                               * 00230000
*                  READ                                               * 00240000
*                      R0 = ADDRESS OF COUNT FIELDS ON TRACK          * 00250000
*                      R1 = ADDRESS OF KEY AND DATA FIELDS ON TRACK   * 00260000
*                  CLOSE                                              * 00270000
*              8 = ERROR OCCURED                                      * 00280000
*                  R0 = REASON CODE  DESCRIPTION                      * 00290001
*                       X'00000001'  UNAUTHORIZED                     * 00300001
*                       X'00000002'  INVALID WORK AREA                * 00310001
*                       X'00000003'  INVALID FUNCTION CALL            * 00320001
*                       X'00000101'  DEVTYPE FAILED                   * 00330001
*                       X'00000103'  READ FORMAT 4 FAILED             * 00340001
*                       X'00000104'  CC INVALID                       * 00350001
*                       X'00000105'  HH ERROR                         * 00360001
*                       X'00000201'  OPEN NOT COMPLETED               * 00370001
*                       X'00000202'  CC INVALID                       * 00380001
*                       X'00000203'  HH ERROR                         * 00390001
*                       X'00000204'  READ HOME ADDRESS FAILED         * 00400001
*                       X'00000205'  READ COUNT FAILED                * 00410001
*                       X'00000301'  CLOSE OF UNOPENED DCB            * 00420001
*                                                                     * 00430001
*********************************************************************** 00440000
*                                                                     * 00450000
* CHANGE LOG:                                                         * 00460000
* MM/DD/YY AAA V.VV DESCRIPTION                                       * 00470000
* 04/03/20 DSK 1.01 CREATED                                           * 00480000
* 01/22/22 DSK 1.02 HANDLE TRACKS WITH DATA AFTER EOF MARKER          * 00490002
*********************************************************************** 00500000
         GBLC  &VER                                                     00510000
&VER     SETC  'V1.02'                                                  00520002
RDTRK    CSECT                                                          00530000
*********************************************************************** 00540000
*        INITIALIZE                                                   * 00550000
*********************************************************************** 00560000
         USING RDTRK,R15                                                00570000
         B     START                   BYPASS PGMID                     00580000
         DROP  R15                                                      00590000
         DC    AL1(L'PGMID)            LENGTH OF PGMID                  00600000
PGMID    DC    C'RDTRK - &VER &SYSDATE &SYSTIME'                        00610000
START    DS    0H                                                       00620000
         STM   R14,R12,12(R13)         SAVE REGISTERS                   00630000
         LR    R12,R15                 LET REG 12 BE BASE               00640000
         USING RDTRK,R12               ESTABLISH BASE                   00650000
*********************************************************************** 00660000
*        INITIALIZE                                                   * 00670000
*********************************************************************** 00680000
         LR    R10,R1                  SAVE PARAMETERS ADDRESS          00690001
         L     R8,4(,R10)              GET WORKAREA ADDRESS             00700000
         L     R1,0(,R10)              GET FUNCTION ADDRESS             00710001
         CLI   0(R1),C'O'              OPEN REQUEST                     00720000
         BNE   INTCSA                  NO                               00730001
         LR    R0,R8                   CLEAR                            00740000
         L     R1,=A(WORKLEN)           THE                             00750001
         SR    R15,R15                   WORK                           00760001
         MVCL  R0,R14                     AREA                          00770001
INTCSA   DS    0H                                                       00780000
         LA    R14,0(,R8)              CHAIN                            00790000
         ST    R13,4(,R14)              SAVE                            00800000
         ST    R14,8(,R13)               AREAS                          00810000
         LR    R13,R14                    TOGETHER                      00820000
         USING WORKAREA,R13                                             00830000
         TESTAUTH FCTN=1               ARE WE AUTHORIZED                00840000
         LTR   R15,R15                 TEST FOR AUTHORIZED              00850001
         BNZ   INTER1                  NO, ERROR                        00860001
         L     R1,0(,R10)              GET FUNCTION ADDRESS             00870001
         CLI   0(R1),C'O'              OPEN REQUEST                     00880000
         BE    INTOPN                  YES                              00890001
         CLC   WRKID01,=CL32'CCW-----------------------------'          00900000
         BNE   INTER2                  ERROR                            00910001
         CLC   WRKID02,=CL32'STATUS--------------------------'       02 00920002
         BNE   INTER2                  ERROR                            00930001
         CLC   WRKID03,=CL32'ECB-----------------------------'          00940000
         BNE   INTER2                  ERROR                            00950001
         CLC   WRKID04,=CL32'IOB-----------------------------'          00960000
         BNE   INTER2                  ERROR                            00970001
         CLC   WRKID05,=CL32'HA------------------------------'          00980000
         BNE   INTER2                  ERROR                            00990001
         CLC   WRKID06,=CL32'R0------------------------------'          01000000
         BNE   INTER2                  ERROR                            01010001
         CLC   WRKID07,=CL32'FMT4----------------------------'          01020000
         BNE   INTER2                  ERROR                            01030001
         CLC   WRKID08,=CL32'JFCB----------------------------'          01040000
         BNE   INTER2                  ERROR                            01050001
         CLC   WRKID09,=CL32'DCB-----------------------------'          01060000
         BNE   INTER2                  ERROR                            01070001
         CLC   WRKID10,=CL32'WORK----------------------------'          01080000
         BNE   INTER2                  ERROR                            01090001
         CLC   WRKID11,=CL32'COUNT---------------------------'          01100000
         BNE   INTER2                  ERROR                            01110001
         CLC   WRKID12,=CL32'BUFFER--------------------------'          01120000
         BNE   INTER2                  ERROR                            01130001
         LA    R15,WORKAREA                                          02 01140002
         A     R15,=A(WRKID13-WORKAREA)                              02 01150002
         USING WRKID13,R15                                           02 01160002
         CLC   WRKID13,=CL32'RDTRKWAEND----------------------'       02 01170002
         DROP  R15                                                   02 01180002
         BNE   INTER2                  ERROR                         02 01190002
         CLI   0(R1),C'R'              READ REQUEST                     01200000
         BE    READ                    YES                              01210001
         CLI   0(R1),C'C'              CLOSE REQUEST                    01220000
         BNE   INTER3                  NO, ERROR                        01230001
*********************************************************************** 01240000
*        CLOSE REQUEST                                                * 01250001
*********************************************************************** 01260000
         LA    R5,WRKDCB               ADDRESS DCB                      01270000
         USING IHADCB,R5                                                01280000
         L     R6,DCBDEBAD             ADDRESS DEB                      01290000
         USING DEBDSECT,R6                                              01300000
         TM    DCBOFLGS,DCBOFOPN       OPEN SUCCESSFULLY INVOKED        01310001
         BNO   CLOSERR1                NO, ERROR                        01320001
         MODESET KEY=ZERO              ALLOW ALTERATION OF DEB          01330000
         MVC   DEBDVMOD(16),WRKSVDEB   RESTORE DEB                      01340000
         MODESET KEY=NZERO             RETORE KEY                       01350000
CLOSE010 DS    0H                                                       01360000
         CLOSE (WRKDCB),MF=(E,WRKOPNLS) CLOSE DCB                       01370001
         DROP  R5                                                       01380000
         DROP  R6                                                       01390000
         B     EXITRC0                 EXIT                             01400001
*********************************************************************** 01410000
*        OPEN  REQUEST                                                * 01420001
*********************************************************************** 01430000
INTOPN   DS    0H                                                       01440000
         L     R1,8(,R10)              GET CCHH ADDRESS                 01450000
         MVC   WRKCCHH,0(R1)           SAVE OFF REQUESTED CCHH          01460000
         MVC   WRKID01,=CL32'CCW-----------------------------'          01470000
         MVC   WRKCCWHA(L'MDLCCWHA),MDLCCWHA INIT READ HA/R0 CCWS       01480001
         L     R0,WRKCCWHA             RELOCATE                         01490001
         AR    R0,R13                   READ HA                         01500001
         ST    R0,WRKCCWHA               CCW                            01510001
         L     R0,WRKCCWHA+8           RELOCATE                         01520001
         AR    R0,R13                   READ R0                         01530001
         ST    R0,WRKCCWHA+8             CCW                            01540001
         LA    R1,WRKCCWRC             READ COUNT CCW AREA              01550001
         LA    R14,MDLCCWRC            MODEL READ COUNT CCWS            01560001
         LA    R15,L'MDLCCWRC(,R1)     END OF MODEL AREA                01570001
INTCCWRC DS    0H                                                       01580000
         MVC   0(8,R1),0(R14)          COPY MODEL READ COUNT CCW        01590001
         L     R0,0(,R1)               RELOCATE                         01600001
         AR    R0,R13                   READ COUNT                      01610001
         ST    R0,0(,R1)                 CCW                            01620001
         LA    R1,8(,R1)               NEXT CCW AREA                    01630001
         LA    R14,8(,R14)             NEXT MODEL CCW                   01640001
         CR    R1,R15                  END OF MODEL CCWS                01650001
         BL    INTCCWRC                NO, CONTINUE                     01660001
         MVC   WRKID02,=CL32'STATUS--------------------------'       02 01670002
         MVC   WRKID03,=CL32'ECB-----------------------------'          01680000
         MVC   WRKID04,=CL32'IOB-----------------------------'          01690000
         MVC   WRKID05,=CL32'HA------------------------------'          01700000
         MVC   WRKID06,=CL32'R0------------------------------'          01710000
         MVC   WRKID07,=CL32'FMT4----------------------------'          01720000
         MVC   WRKID08,=CL32'JFCB----------------------------'          01730000
         MVC   WRKID09,=CL32'DCB-----------------------------'          01740000
         MVC   WRKID10,=CL32'WORK----------------------------'       02 01750002
         MVC   WRKID11,=CL32'COUNT---------------------------'       02 01760002
         MVC   WRKID12,=CL32'BUFFER--------------------------'       02 01770002
         LA    R15,WORKAREA                                          02 01780002
         A     R15,=A(WRKID13-WORKAREA)                              02 01790002
         USING WRKID13,R15                                           02 01800002
         MVC   WRKID13,=CL32'RDTRKWAEND----------------------'       02 01810002
         DROP  R15                                                   02 01820002
         MVC   WRKDCB(L'MDLDCB),MDLDCB                                  01830000
         LA    R5,WRKDCB               ADDRESS DCB                      01840000
         USING IHADCB,R5                                                01850000
         L     R1,12(,R10)             GET DDNAME ADDRESS               01860000
         MVC   DCBDDNAM,0(R1)          SET DDNAME IN DCB                01870000
         LA    R0,WRKIOB               GET IOB ADDRESS                  01880001
         STCM  R0,7,DCBIOBAA           SET IOB IN DCB                   01890001
         LA    R0,EOF                  GET END OF DATA ROUTINE ADDRESS  01900001
         STCM  R0,7,DCBEODA            SET IN DCB                       01910001
         LA    R0,WRKDCBXT             GET EXIT LIST                    01920001
         STCM  R0,7,DCBEXLSA           SET IN DCB                       01930001
         MVC   WRKOPNLS(L'MDLOPNLS),MDLOPNLS OPEN/CLOSE PARAMETER LIST  01940001
         LA    R0,WRKJFCB              JFCB ADDRESS                     01950001
         ST    R0,WRKDCBXT             STORE IN EXIT LIST               01960001
         MVI   WRKDCBXT,X'87'          SET READ JFCB AND END OF LIST    01970001
         MVC   WRKSRCLS(L'MDLSRCLS),MDLSRCLS OBTAIN PARAMETER           01980001
         LA    R1,WRKJFCB              DSNAME ADDRESS                   01990001
         USING JFCB,R1                                                  02000001
         ST    R1,WRKSRCLS+4           SAVE IN OBTAIN PARAMETER LIST    02010001
         LA    R0,JFCBVOLS             VOLUME SERIAL NUMBER             02020001
         DROP  R1                                                       02030001
         ST    R0,WRKSRCLS+8           SAVE IN OBTAIN PARAMETER LIST    02040001
         LA    R0,WRKFMT4              FORMAT 4 DSCB AREA               02050001
         ST    R0,WRKSRCLS+12          SAVE IN OBTAIN PARAMETER LIST    02060001
         MVC   WRKID10,=CL32'WORK----------------------------'          02070000
         MVC   WRKID11,=CL32'COUNT---------------------------'          02080000
         MVC   WRKID12,=CL32'BUFFER--------------------------'          02090000
*********************************************************************** 02100000
*        DEVICE TYPE                                                  * 02110000
*********************************************************************** 02120000
         DEVTYPE DCBDDNAM,WRKDEVAR,DEVTAB                               02130000
         LTR   R15,R15                 RETURN CODE OKAY?                02140000
         BNE   DEVERR1                 NO, ERROR                        02150000
         CLI   WRKDEVAR+2,X'20'        DASD?                            02160000
         BNE   DEVERR2                 NO, ERROR                        02170000
*********************************************************************** 02180000
*        OPEN DASD DCB                                                * 02190000
*********************************************************************** 02200000
         RDJFCB  WRKDCB,MF=(E,WRKOPNLS) READ JFCB                       02210000
         LA    R1,WRKJFCB              DSNAME ADDRESS                   02220001
         USING JFCB,R1                                                  02230001
         MVI   JFCBDSNM,X'04'          SET UP JFCB                      02240001
         MVC   JFCBDSNM+1(L'JFCBDSNM-1),JFCBDSNM WITH DSNAME            02250001
         DROP  R1                                                       02260001
         OBTAIN WRKSRCLS               GET THE FORMAT 4 DSCB            02270000
         CLI   WRKFMT4,C'4'            IS THIS A FORMAT 4 DSCB          02280001
         BNE   DEVERR3                 NO, ERROR                        02290000
         LH    R3,WRKFMT4+18           NR OF CYLS                       02300000
         LR    R4,R3                   SAVE NUMBER OF CYLINDERS         02310000
         BCTR  R4,0                    MAX CYL NUMBER FOR TESTS         02320000
         STH   R4,WRKMAXCY             SAVE MAX CYLS                    02330000
         LH    R4,WRKFMT4+20           TRACKS PER CYL                   02340000
         BCTR  R4,0                    LESS ONE FOR MAX HEAD NR         02350000
         STH   R4,WRKMAXTR             SAVE IT                          02360000
         MH    R3,WRKFMT4+20           CYLS X TRACKS/CYL                02370000
         STH   R3,WRKALLTR             TOTAL TRACKS ON PACK             02380000
         CLC   WRKCCHH(2),WRKMAXCY     IS CYLINDER VALID                02390001
         BH    CCHHER1                 NO, ERROR                        02400001
         CLC   WRKCCHH+2(2),WRKMAXTR   IS TRACK VALID                   02410001
         BH    CCHHER2                 NO, ERROR                        02420001
         OPEN  (WRKDCB),TYPE=J,MF=(E,WRKOPNLS) OPEN DCB                 02430001
         L     R6,DCBDEBAD             ADDRESS DEB                      02440000
         USING DEBDSECT,R6                                              02450000
*********************************************************************** 02460000
*        SET DEB TO ALLOW WHOLE VOLUME ACCESS                         * 02470000
*********************************************************************** 02480000
         MODESET KEY=ZERO              ALLOW ALTERATION OF DEB          02490001
         MVC   WRKSVDEB(16),DEBDVMOD   SAVE OFF DEB                     02500000
         MVC   DEBDVMOD,X'40'          SET SEEKS OK, WRITES NOT OK      02510000
         MVC   DEBSTRCC,=XL2'00'       SET LOW                          02520000
         MVC   DEBSTRHH,=XL2'00'        ADDRESS                         02530000
         MVC   DEBENDCC,WRKMAXCY       SET HIGH                         02540000
         MVC   DEBENDHH,WRKMAXTR        ADDRESS                         02550000
         MVC   DEBNMTRK,WRKALLTR       SET NUMBER OF TRACKS             02560000
         NI    DEBPROTG,X'0F'          SET PROTECT KEY TO ZEROS         02570001
         MODESET KEY=NZERO             RESORE KEY                       02580000
         B     EXITRC0                 OPEN COMPLETED                   02590000
         DROP  R5                                                       02600000
         DROP  R6                                                       02610000
*********************************************************************** 02620000
*        READ TRACK REQUEST                                           * 02630001
*********************************************************************** 02640000
READ     DS    0H                                                       02650000
         XC    WRKHAIOB,WRKHAIOB       CLEAR RESIDUAL                02 02660002
         XC    WRKHAECB,WRKHAECB        RESIDUAL                     02 02670002
         XC    WRKCTIOB,WRKCTIOB         DIAGNOSTIC                  02 02680002
         XC    WRKCTECB,WRKCTECB          INFORMATION                02 02690002
         XC    WRKDTIOB,WRKDTIOB                                     02 02700002
         XC    WRKDTECB,WRKDTECB                                     02 02710002
         LA    R0,WRKCOUNT             CLEAR                         02 02720002
         L     R1,=A(WRKCNTLN)          COUNT                        02 02730002
         SR    R15,R15                   AREA                        02 02740002
         MVCL  R0,R14                                                02 02750002
         LA    R0,WRKCCWKD             CLEAR                         02 02760002
         L     R1,=A(WRKCCWRE-WRKCCWKD) READ                         02 02770002
         SR    R15,R15                   TRACK                       02 02780002
         MVCL  R0,R14                     CCWS                       02 02790002
         LA    R0,WORKAREA                                           02 02800002
         A     R0,=A(WRKBUF-WORKAREA)  CLEAR                         02 02810002
         L     R1,=A(WRKBUFLN)          BUFFER                       02 02820002
         SR    R15,R15                                               02 02830002
         MVCL  R0,R14                                                02 02840002
         XC    WRKIOB,WRKIOB           CLEAR IOB                     02 02850002
         LA    R5,WRKDCB               ADDRESS DCB                      02860000
         USING IHADCB,R5                                                02870000
         L     R6,DCBDEBAD             ADDRESS DEB                      02880000
         USING DEBDSECT,R6                                              02890000
         TM    DCBOFLGS,DCBOFOPN       OPEN SUCCESSFULLY COMPLETED      02900001
         BNO   READERR1                NO, ERROR                        02910001
         MVI   WRKIOBF1,X'42'          INITIALIZE IOB                02 02920002
         LA    R0,WRKECB               ECB ADDRESS                      02930001
         STCM  R0,7,WRKIOBEC            INTO IOB                        02940001
         LA    R0,WRKDCB               DCB ADDRESS                      02950001
         STCM  R0,7,WRKIOBDC            INTO IOB                        02960001
         L     R1,8(,R10)              GET CCHH ADDRESS                 02970000
         MVC   WRKCCHH,0(R1)           SAVE OFF REQUESTED CCHH          02980000
         CLC   WRKCCHH(2),WRKMAXCY     VALID CC?                        02990001
         BH    READERR2                NO, ERROR                        03000001
         CLC   WRKCCHH+2(2),WRKMAXTR   VALID HH?                        03010001
         BH    READERR3                NO, ERROR                        03020001
*********************************************************************** 03030000
*        READ TRACKS HOME ADDRESS AND RECORD ZERO                     * 03040000
*********************************************************************** 03050000
         LA    R0,WRKCCWHA             READ HOME ADDRESS CCW            03060000
         STCM  R0,7,WRKIOBAD            INTO IOB                        03070001
         MVC   WRKIOBSK+3(5),WRKCCHH   SET UP CYL SEEK ADDR             03080000
         XC    WRKECB,WRKECB           CLEAR ECB                        03090001
         LA    R0,1                    COUNT                         02 03100002
         A     R0,WRKIOCNT              NUMBER                       02 03110002
         ST    R0,WRKIOCNT               OF I/O                      02 03120002
         EXCP  WRKIOB                  READ HA/R0                       03130001
         WAIT  ,ECB=WRKECB             WAIT FOR COMPLETION              03140001
         MVC   WRKHAIOB,WRKIOB         COPY IOB                      02 03150002
         MVC   WRKHAECB,WRKECB          AND ECB FOR DIAGNOSTICS      02 03160002
         CLI   WRKECB,X'7F'            IS I/O OKAY?                     03170000
         BNE   RDHAERR                 NO, EREROR                       03180000
*********************************************************************** 03190000
*        READ ALL COUNTS ON TRACK                                     * 03200001
*********************************************************************** 03210000
READTRK  DS    0H                                                       03220000
         MVI   WRKRECNO,1              START WITH RECORD 1              03230001
         LA    R0,WRKCCWRC             GET READ COUNT CCWS ADDRESS      03240001
         STCM  R0,7,WRKIOBAD           SAVE IN IOB                      03250001
         MVC   WRKIOBSK+3(5),WRKCCHH   SET UP SEEK ADDRESS IN IOB       03260001
         XC    WRKECB,WRKECB           CLEAR ECB                        03270001
         LA    R0,1                    COUNT                         02 03280002
         A     R0,WRKIOCNT              NUMBER                       02 03290002
         ST    R0,WRKIOCNT               OF I/O                      02 03300002
         EXCP  WRKIOB                  READ ALL COUNTS ON TRACK         03310001
         WAIT  ,ECB=WRKECB             WAIT FOR COMPLETION              03320001
         MVC   WRKCTIOB,WRKIOB         COPY IOB                      02 03330002
         MVC   WRKCTECB,WRKECB          AND ECB FOR DIAGNOSTICS      02 03340002
         CLI   WRKECB,X'7F'            IS I/O OKAY?                     03350000
         BE    RDCNTOK                 NO, EREROR                       03360001
         CLC   WRKCOUNT(8),=XL8'00'    IS TRACK EMPTY?                  03370001
         BE    EOF                     YES, WERE DONE                   03380001
*********************************************************************** 03390001
*        READ ALL KEY AND DATA ON TRACK                               * 03400001
*********************************************************************** 03410001
*        BUILD READ KEY AND DATA CHANNEL PROGRAM                        03420000
RDCNTOK  DS    0H                                                       03430000
         LA    R1,WRKCOUNT             COUNT = CCCC HHHH RR KK RRRR  02 03440002
         LA    R15,WRKCCWKD            CCW AREA=0E AAAAAA FF LLLLLL  02 03450002
         LA    R14,WORKAREA                                          02 03460002
         A     R14,=A(WRKBUF-WORKAREA)  UFFER START                  02 03470002
BLDRD    DS    0H                                                       03480000
         LA    R0,WRKCCWRE             END OF CCW AREA               02 03490002
         CR    R15,R0                  WE NOW PAST END OF CCW AREA?  02 03500002
         BNL   BLDRDND                 YES TO MANY EOF ON TRACK      02 03510002
         MVI   0(R15),X'0E'            READ KEY AND DATA COMMAND     02 03520002
         STCM  R14,7,1(R15)            DATA ADDRESS                  02 03530002
         MVI   4(R15),CCWCC+CCWSLI     COMMAND CHAIN AND SLI         02 03540002
         SR    R0,R0                   CLEAR FOR LENGTH              02 03550002
         IC    R0,5(,R1)               KEY LENGTH FROM COUNT         02 03560002
         AH    R0,6(,R1)               DATA LENGTH FROM COUNT        02 03570002
         LTR   R0,R0                   LENGTH ZERO                   02 03580002
         BNE   BLDRDNEF                NO, OK                        02 03590002
*        WE HIT AN EOF ON TRACK                                      02 03600002
*        READ IT'S COUNT AND NEXT RECORD COUNT                       02 03610002
*        THIS ORIENTS NEXT READ TO NEXT RECORD ON TRACK              02 03620002
         CLC   8(8,R1),=XL8'00'        LAST EOF ON TRACK             02 03630002
         BE    BLDRDND                 YES, CCWS ALL BUILT           02 03640002
         MVI   0(R15),X'12'            READ COUNT OF EOF RECORD      02 03650002
         MVI   4(R15),CCWCC+CCWSLI+CCWSKIP COMMAND CHAIN+SLI+SKIP    02 03660002
         LA    R0,8                    LENGTH OF COUNT               02 03670002
         STH   R0,6(,R15)              SAVE IN CCW                   02 03680002
         LA    R15,8(,R15)             NEXT CCW                      02 03690002
         LA    R0,WRKCCWRE             END OF CCW AREA               02 03700002
         CR    R15,R0                  WE NOW PAST END OF CCW AREA?  02 03710002
         BNL   BLDRDND                 YES TO MANY EOF ON TRACK      02 03720002
         MVI   0(R15),X'12'            READ COUNT OF NEXT RECORD     02 03730002
         STCM  R14,7,1(R15)            DATA ADDRESS                  02 03740002
         MVI   4(R15),CCWCC+CCWSLI+CCWSKIP COMMAND CHAIN+SLI+SKIP    02 03750002
         LA    R0,8                    LENGTH OF COUNT               02 03760002
         STH   R0,6(,R15)              SAVE IN CCW                   02 03770002
         LA    R15,8(,R15)             NEXT CCW                      02 03780002
         B     BLDRD                                                 02 03790002
BLDRDNEF DS    0H                                                       03800000
         STH   R0,6(,R15)              SAVE LENGTH IN CCW            02 03810002
         LA    R1,8(,R1)               NEXT CCW                      02 03820002
         LA    R15,8(,R15)             NEXT COUNT AREA               02 03830002
         AR    R14,R0                  NEXT BUFFER ADDRESS           02 03840002
         CLC   0(8,R1),=XL8'00'        END OF COUNTS                 02 03850002
         BE    BLDRDND                 YES, CCWS ALL BUILT           02 03860002
         CLC   WRKCOUNT(8),0(R1)       WRAP AROUND TO START OF TRACK 02 03870002
         BNE   BLDRD                   NO, CONTINUE BUILD READS      02 03880002
         LA    R0,WRKCOUNT+WRKCNTLN    END OF COUNTS ADDRESS         02 03890002
BLDRDCL  DS    0H                                                       03900000
         CR    R1,R0                   END OF COUNTS                 02 03910002
         BNL   BLDRDND                 YES, DONE                     02 03920002
         XC    0(8,R1),0(R1)           CLEAR WRAPPING COUNT          02 03930002
         LA    R1,8(,R1)               NEXT COUNT                    02 03940002
         B     BLDRDCL                 HANDLE NEXT ONE               02 03950002
BLDRDND  DS    0H                                                       03960000
         SH    R15,=H'8'               TO LAST CCW                   02 03970002
         NI    4(R15),255-CCWCC        REMOVE COMMAND CHAINING       02 03980002
*        READ KEY AND DATA                                              03990000
         LA    R0,WRKCCWKD             GET READ KEY/DATA CCWS ADDR   02 04000002
         STCM  R0,7,WRKIOBAD           SAVE IN IOB                   02 04010002
         MVC   WRKIOBSK+3(5),WRKCCHH   SET UP SEEK ADDRESS IN IOB    02 04020002
         XC    WRKECB,WRKECB           CLEAR ECB                     02 04030002
         LA    R0,1                    COUNT                         02 04040002
         A     R0,WRKIOCNT              NUMBER                       02 04050002
         ST    R0,WRKIOCNT               OF I/O                      02 04060002
         EXCP  WRKIOB                  READ ALL COUNTS ON TRACK      02 04070002
         WAIT  ECB=WRKECB              WAIT FOR COMPLETION           02 04080002
         MVC   WRKDTIOB,WRKIOB         COPY IOB                      02 04090002
         MVC   WRKDTECB,WRKECB          AND ECB FOR DIAGNOSTICS      02 04100002
         B     READDONE                DONE                          02 04110002
*********************************************************************** 04120000
*         READ COMPLETE                                               * 04130000
*********************************************************************** 04140000
EOF      DS    0H                                                       04150000
         MVI   WRKECB,X'EF'            SET END OF FILE               02 04160002
READDONE DS    0H                                                    02 04170002
         LA    R0,WRKCOUNT             COUNT AREA                       04180000
         LA    R1,WORKAREA                                           02 04190002
         A     R1,=A(WRKBUF-WORKAREA)  TRACK BUFFER                  02 04200002
         DROP  R5                                                       04210000
         DROP  R6                                                       04220000
*********************************************************************** 04230000
*        EXIT                                                         * 04240000
*********************************************************************** 04250000
EXITRC0  DS    0H                                                       04260000
         SLR   R15,R15                 SET ZERO RETURN CODE             04270000
         L     R13,4(,R13)             RESTORE SAVE AREA ADDRESS        04280000
         L     R14,12(,R13)            RESTORE RETURN ADDRESS           04290000
         LM    R2,R12,28(R13)          RESTORE REGISTERS                04300000
         BR    R14                     EXIT                             04310000
*********************************************************************** 04320000
*        ERROR EXIT                                                   * 04330000
*********************************************************************** 04340000
QUIT     DS    0H                                                       04350000
         LR    R0,R2                   REASON CODE                      04360000
         LA    R15,8                   SET RETURN CODE                  04370000
         L     R13,4(,R13)             RESTORE SAVE AREA ADDRESS        04380000
         L     R14,12(,R13)            RESTORE RETURN ADDRESS           04390000
         LM    R1,R12,24(R13)          RESTORE REGISTERS                04400000
         BR    R14                     EXIT                             04410000
*********************************************************************** 04420000
*        ERRORS                                                       * 04430000
*********************************************************************** 04440000
INTER1   DS    0H                                                       04450000
         LA    R2,(256*0)+1            UNAUTHORIZED                     04460000
         B     QUIT                    EXIT                             04470001
*                                                                       04480000
INTER2   DS    0H                                                       04490000
         LA    R2,(256*0)+2            INVALID WORK AREA                04500000
         B     QUIT                    EXIT                             04510001
*                                                                       04520000
INTER3   DS    0H                                                       04530000
         LA    R2,(256*0)+3            INVALID FUNCTION CALL            04540000
         B     QUIT                    EXIT                             04550001
*                                                                       04560000
DEVERR1  DS    0H                                                       04570000
         LA    R2,(256*1)+1            DEVTYPE FAILED                   04580000
         B     ERRXIT                  CLOSE AND EXIT                   04590001
*                                                                       04600000
DEVERR2  DS    0H                                                       04610000
         LA    R2,(256*1)+2            DEVICE NOT DASD                  04620000
         B     ERRXIT                  CLOSE AND EXIT                   04630001
*                                                                       04640000
DEVERR3  DS    0H                                                       04650000
         LA    R2,(256*1)+3            READ FORMAT 4 FAILED             04660000
         B     ERRXIT                  CLOSE AND EXIT                   04670001
*                                                                       04680000
CCHHER1  DS    0H                                                       04690000
         LA    R2,(256*1)+4            CC INVALID                       04700000
         B     ERRXIT                  CLOSE AND EXIT                   04710001
*                                                                       04720000
CCHHER2  DS    0H                                                       04730000
         LA    R2,(256*1)+5            HH ERROR                         04740000
         B     ERRXIT                  CLOSE AND EXIT                   04750001
*                                                                       04760000
ERRXIT   DS    0H                                                       04770000
         CLOSE (WRKDCB),MF=(E,WRKOPNLS) CLOSE DCB                       04780001
         B     QUIT                    EXIT                             04790001
*                                                                       04800000
READERR1 DS    0H                                                       04810000
         LA    R2,(256*2)+1            OPEN NOT COMPLETED               04820000
         B     QUIT                    EXIT                             04830001
*                                                                       04840000
READERR2 DS    0H                                                       04850000
         LA    R2,(256*2)+2            CC INVALID                       04860000
         B     ERRXIT                  CLOSE AND EXIT                   04870001
*                                                                       04880000
READERR3 DS    0H                                                       04890000
         LA    R2,(256*2)+3            HH ERROR                         04900000
         B     ERRXIT                  CLOSE AND EXIT                   04910001
*                                                                       04920000
RDHAERR  DS    0H                                                       04930000
         LA    R2,(256*2)+4            READ HOME ADDRESS FAILED         04940000
         B     QUIT                    EXIT                             04950001
*                                                                       04960000
RDCNTERR DS    0H                                                       04970000
         LA    R2,(256*2)+5            READ COUNT FAILED                04980000
         B     QUIT                    EXIT                             04990001
*                                                                       05000000
CLOSERR1 DS    0H                                                       05010000
         LA    R2,(256*3)+1            CLOSE OF UNOPENED DCB            05020000
         B     QUIT                    EXIT                             05030001
*********************************************************************** 05040000
*        CONSTANTS                                                    * 05050000
*********************************************************************** 05060000
         LTORG ,                                                        05070000
*********************************************************************** 05080000
*        MODEL CONSTANTS                                              * 05090000
*********************************************************************** 05100000
BGNCCWHA CCW   X'1A',WRKHA-WORKAREA,CCWCC,5     READ HOME ADDRESS       05110000
         CCW   X'16',WRKR0-WORKAREA,CCWSLI,4    READ RECORD ZERO        05120000
MDLCCWHA EQU   BGNCCWHA,*-BGNCCWHA                                      05130000
*                                                                       05140000
BGNDCB   DCB   DSORG=PS,DDNAME=XXXXXXXX,MACRF=(E),                     *05150000
               EXLST=WRKDCBXT-WORKAREA,IOBAD=WRKIOB-WORKAREA            05160000
MDLDCB   EQU   BGNDCB,*-BGNDCB                                          05170000
*                                                                       05180000
BGNOPNLS OPEN  (0,(INPUT)),MF=L                                         05190000
MDLOPNLS EQU   BGNOPNLS,*-BGNOPNLS                                      05200000
*                                                                       05210000
BGNSRCLS CAMLST SEARCH,0,0,WRKFMT4-WORKAREA                             05220000
MDLSRCLS EQU   BGNSRCLS,*-BGNSRCLS                                      05230000
*                                                                       05240000
BGNCCWRC CCW   X'12',WRKCOUNT+00*8-WORKAREA,CCWSLI+CCWCC,8       01     05250000
         CCW   X'12',WRKCOUNT+01*8-WORKAREA,CCWSLI+CCWCC,8       02     05260000
         CCW   X'12',WRKCOUNT+02*8-WORKAREA,CCWSLI+CCWCC,8       03     05270000
         CCW   X'12',WRKCOUNT+03*8-WORKAREA,CCWSLI+CCWCC,8       04     05280000
         CCW   X'12',WRKCOUNT+04*8-WORKAREA,CCWSLI+CCWCC,8       05     05290000
         CCW   X'12',WRKCOUNT+05*8-WORKAREA,CCWSLI+CCWCC,8       06     05300000
         CCW   X'12',WRKCOUNT+06*8-WORKAREA,CCWSLI+CCWCC,8       07     05310000
         CCW   X'12',WRKCOUNT+07*8-WORKAREA,CCWSLI+CCWCC,8       08     05320000
         CCW   X'12',WRKCOUNT+08*8-WORKAREA,CCWSLI+CCWCC,8       09     05330000
         CCW   X'12',WRKCOUNT+09*8-WORKAREA,CCWSLI+CCWCC,8       10     05340000
         CCW   X'12',WRKCOUNT+10*8-WORKAREA,CCWSLI+CCWCC,8       11     05350000
         CCW   X'12',WRKCOUNT+11*8-WORKAREA,CCWSLI+CCWCC,8       12     05360000
         CCW   X'12',WRKCOUNT+12*8-WORKAREA,CCWSLI+CCWCC,8       13     05370000
         CCW   X'12',WRKCOUNT+13*8-WORKAREA,CCWSLI+CCWCC,8       14     05380000
         CCW   X'12',WRKCOUNT+14*8-WORKAREA,CCWSLI+CCWCC,8       15     05390000
         CCW   X'12',WRKCOUNT+15*8-WORKAREA,CCWSLI+CCWCC,8       16     05400000
         CCW   X'12',WRKCOUNT+16*8-WORKAREA,CCWSLI+CCWCC,8       17     05410000
         CCW   X'12',WRKCOUNT+17*8-WORKAREA,CCWSLI+CCWCC,8       18     05420000
         CCW   X'12',WRKCOUNT+18*8-WORKAREA,CCWSLI+CCWCC,8       19     05430000
         CCW   X'12',WRKCOUNT+19*8-WORKAREA,CCWSLI+CCWCC,8       20     05440000
         CCW   X'12',WRKCOUNT+20*8-WORKAREA,CCWSLI+CCWCC,8       21     05450000
         CCW   X'12',WRKCOUNT+21*8-WORKAREA,CCWSLI+CCWCC,8       22     05460000
         CCW   X'12',WRKCOUNT+22*8-WORKAREA,CCWSLI+CCWCC,8       23     05470000
         CCW   X'12',WRKCOUNT+23*8-WORKAREA,CCWSLI+CCWCC,8       24     05480000
         CCW   X'12',WRKCOUNT+24*8-WORKAREA,CCWSLI+CCWCC,8       25     05490000
         CCW   X'12',WRKCOUNT+25*8-WORKAREA,CCWSLI+CCWCC,8       26     05500000
         CCW   X'12',WRKCOUNT+26*8-WORKAREA,CCWSLI+CCWCC,8       27     05510000
         CCW   X'12',WRKCOUNT+27*8-WORKAREA,CCWSLI+CCWCC,8       28     05520000
         CCW   X'12',WRKCOUNT+28*8-WORKAREA,CCWSLI+CCWCC,8       29     05530000
         CCW   X'12',WRKCOUNT+29*8-WORKAREA,CCWSLI+CCWCC,8       30     05540000
         CCW   X'12',WRKCOUNT+30*8-WORKAREA,CCWSLI+CCWCC,8       31     05550000
         CCW   X'12',WRKCOUNT+31*8-WORKAREA,CCWSLI+CCWCC,8       32     05560000
         CCW   X'12',WRKCOUNT+32*8-WORKAREA,CCWSLI+CCWCC,8       33     05570000
         CCW   X'12',WRKCOUNT+33*8-WORKAREA,CCWSLI+CCWCC,8       34     05580000
         CCW   X'12',WRKCOUNT+34*8-WORKAREA,CCWSLI+CCWCC,8       35     05590000
         CCW   X'12',WRKCOUNT+35*8-WORKAREA,CCWSLI+CCWCC,8       36     05600000
         CCW   X'12',WRKCOUNT+36*8-WORKAREA,CCWSLI+CCWCC,8       37     05610000
         CCW   X'12',WRKCOUNT+37*8-WORKAREA,CCWSLI+CCWCC,8       38     05620000
         CCW   X'12',WRKCOUNT+38*8-WORKAREA,CCWSLI+CCWCC,8       39     05630000
         CCW   X'12',WRKCOUNT+39*8-WORKAREA,CCWSLI+CCWCC,8       40     05640000
         CCW   X'12',WRKCOUNT+40*8-WORKAREA,CCWSLI+CCWCC,8       41     05650000
         CCW   X'12',WRKCOUNT+41*8-WORKAREA,CCWSLI+CCWCC,8       42     05660000
         CCW   X'12',WRKCOUNT+42*8-WORKAREA,CCWSLI+CCWCC,8       43     05670000
         CCW   X'12',WRKCOUNT+43*8-WORKAREA,CCWSLI+CCWCC,8       44     05680000
         CCW   X'12',WRKCOUNT+44*8-WORKAREA,CCWSLI+CCWCC,8       45     05690000
         CCW   X'12',WRKCOUNT+45*8-WORKAREA,CCWSLI+CCWCC,8       46     05700000
         CCW   X'12',WRKCOUNT+46*8-WORKAREA,CCWSLI+CCWCC,8       47     05710000
         CCW   X'12',WRKCOUNT+47*8-WORKAREA,CCWSLI+CCWCC,8       48     05720000
         CCW   X'12',WRKCOUNT+48*8-WORKAREA,CCWSLI+CCWCC,8       49     05730000
         CCW   X'12',WRKCOUNT+49*8-WORKAREA,CCWSLI+CCWCC,8       50     05740000
         CCW   X'12',WRKCOUNT+50*8-WORKAREA,CCWSLI+CCWCC,8       51     05750000
         CCW   X'12',WRKCOUNT+51*8-WORKAREA,CCWSLI+CCWCC,8       52     05760000
         CCW   X'12',WRKCOUNT+52*8-WORKAREA,CCWSLI+CCWCC,8       53     05770000
         CCW   X'12',WRKCOUNT+53*8-WORKAREA,CCWSLI+CCWCC,8       54     05780000
         CCW   X'12',WRKCOUNT+54*8-WORKAREA,CCWSLI+CCWCC,8       55     05790000
         CCW   X'12',WRKCOUNT+55*8-WORKAREA,CCWSLI+CCWCC,8       56     05800000
         CCW   X'12',WRKCOUNT+56*8-WORKAREA,CCWSLI+CCWCC,8       57     05810000
         CCW   X'12',WRKCOUNT+57*8-WORKAREA,CCWSLI+CCWCC,8       58     05820000
         CCW   X'12',WRKCOUNT+58*8-WORKAREA,CCWSLI+CCWCC,8       59     05830000
         CCW   X'12',WRKCOUNT+59*8-WORKAREA,CCWSLI+CCWCC,8       60     05840000
         CCW   X'12',WRKCOUNT+60*8-WORKAREA,CCWSLI+CCWCC,8       61     05850000
         CCW   X'12',WRKCOUNT+61*8-WORKAREA,CCWSLI+CCWCC,8       62     05860000
         CCW   X'12',WRKCOUNT+62*8-WORKAREA,CCWSLI+CCWCC,8       63     05870000
         CCW   X'12',WRKCOUNT+63*8-WORKAREA,CCWSLI+CCWCC,8       64     05880000
         CCW   X'12',WRKCOUNT+64*8-WORKAREA,CCWSLI+CCWCC,8       65     05890000
         CCW   X'12',WRKCOUNT+65*8-WORKAREA,CCWSLI+CCWCC,8       66     05900000
         CCW   X'12',WRKCOUNT+66*8-WORKAREA,CCWSLI+CCWCC,8       67     05910000
         CCW   X'12',WRKCOUNT+67*8-WORKAREA,CCWSLI+CCWCC,8       68     05920000
         CCW   X'12',WRKCOUNT+68*8-WORKAREA,CCWSLI+CCWCC,8       69     05930000
         CCW   X'12',WRKCOUNT+69*8-WORKAREA,CCWSLI+CCWCC,8       70     05940000
         CCW   X'12',WRKCOUNT+70*8-WORKAREA,CCWSLI+CCWCC,8       71     05950000
         CCW   X'12',WRKCOUNT+71*8-WORKAREA,CCWSLI+CCWCC,8       72     05960000
         CCW   X'12',WRKCOUNT+72*8-WORKAREA,CCWSLI+CCWCC,8       73     05970000
         CCW   X'12',WRKCOUNT+73*8-WORKAREA,CCWSLI+CCWCC,8       74     05980000
         CCW   X'12',WRKCOUNT+74*8-WORKAREA,CCWSLI+CCWCC,8       75     05990000
         CCW   X'12',WRKCOUNT+75*8-WORKAREA,CCWSLI+CCWCC,8       76     06000000
         CCW   X'12',WRKCOUNT+76*8-WORKAREA,CCWSLI+CCWCC,8       77     06010000
         CCW   X'12',WRKCOUNT+77*8-WORKAREA,CCWSLI+CCWCC,8       78     06020000
         CCW   X'12',WRKCOUNT+78*8-WORKAREA,CCWSLI+CCWCC,8       79     06030000
         CCW   X'12',WRKCOUNT+79*8-WORKAREA,CCWSLI+CCWCC,8       80     06040000
         CCW   X'12',WRKCOUNT+80*8-WORKAREA,CCWSLI+CCWCC,8       81     06050000
         CCW   X'12',WRKCOUNT+81*8-WORKAREA,CCWSLI+CCWCC,8       82     06060000
         CCW   X'12',WRKCOUNT+82*8-WORKAREA,CCWSLI+CCWCC,8       83     06070000
         CCW   X'12',WRKCOUNT+83*8-WORKAREA,CCWSLI+CCWCC,8       84     06080000
         CCW   X'12',WRKCOUNT+84*8-WORKAREA,CCWSLI+CCWCC,8       85     06090000
         CCW   X'12',WRKCOUNT+85*8-WORKAREA,CCWSLI+CCWCC,8       86     06100000
         CCW   X'12',WRKCOUNT+86*8-WORKAREA,CCWSLI+CCWCC,8       87     06110000
         CCW   X'12',WRKCOUNT+87*8-WORKAREA,CCWSLI+CCWCC,8       88     06120000
         CCW   X'12',WRKCOUNT+88*8-WORKAREA,CCWSLI+CCWCC,8       89     06130000
         CCW   X'12',WRKCOUNT+89*8-WORKAREA,CCWSLI,8             90     06140000
MDLCCWRC EQU   BGNCCWRC,*-BGNCCWRC                                      06150000
*                                                                       06160000
         DC    (((((*-RDTRK)/256)+1)*256)-(*-RDTRK))X'CC'               06170001
*********************************************************************** 06180000
*        WORK AREAS                                                   * 06190000
*********************************************************************** 06200000
         RDTRKWA                                                        06210000
*********************************************************************** 06220000
*        EQUATES AND DSECTS                                           * 06230000
*********************************************************************** 06240000
R0       EQU   0                                                        06250000
R1       EQU   1                                                        06260000
R2       EQU   2                                                        06270000
R3       EQU   3                                                        06280000
R4       EQU   4                                                        06290000
R5       EQU   5                                                        06300000
R6       EQU   6                                                        06310000
R7       EQU   7                                                        06320000
R8       EQU   8                                                        06330000
R9       EQU   9                                                        06340000
R10      EQU   10                                                       06350000
R11      EQU   11                                                       06360000
R12      EQU   12                                                       06370000
R13      EQU   13                                                       06380000
R14      EQU   14                                                       06390000
R15      EQU   15                                                       06400000
*                                                                       06410000
*                                                                       06420000
*                                                                       06430000
CCWDC    EQU   X'80'                   DATA CHAINING                    06440000
CCWCC    EQU   X'40'                   COMMAND CHAINING                 06450000
CCWSLI   EQU   X'20'                   SUPPRESS INCORRECT LENGTH        06460000
CCWSKIP  EQU   X'10'                   SUPPRESS DATA TRANSFER           06470000
CCWPCI   EQU   X'08'                   PROGRAM CONTROLLED INTERRUPT     06480000
CCWIDA   EQU   X'04'                   CHANNEL INDIRECT ADDRESSING      06490000
*                                                                       06500000
*                                                                       06510000
*                                                                       06520000
DEBDSECT DSECT                                                          06530000
         DS    CL24                    DEB BASIC SECTION                06540000
DEBPROTG DS    C                       DEB USER TASK PKEY               06550000
         DS    CL7                                                      06560000
DEBDVMOD DS    C                       FILE MASK                        06570000
DEBUCBA  DS    CL3                     ADDR UCB                         06580000
DEBBINUM DS    CL2                     BIN NUMBER                       06590000
DEBSTRCC DS    CL2                     CYL - START OF EXTENT            06600000
DEBSTRHH DS    CL2                     HEAD - START OF EXTENT           06610000
DEBENDCC DS    CL2                     CYL - END OF EXTENT              06620000
DEBENDHH DS    CL2                     HEAD - END OF EXTENT             06630000
DEBNMTRK DS    CL2                     NUMBER TRACKS IN EXTENT          06640000
*                  EXCP ACCESS METHOD DEPENDENT SECTION                 06650000
DEBVOLSQ DS    CL2                                                      06660000
DEBVOLNM DS    CL2                                                      06670000
         DS    CL8                                                      06680000
*                                                                       06690000
*                                                                       06700000
*                                                                       06710000
         DCBD  ,                                                        06720000
DSCBFMT4 DSECT ,                                                        06730000
         IECSDSL1 4                                                     06740000
JFCB     DSECT ,                                                        06750001
         IEFJFCBN LIST=YES                                              06760001
         END                                                            06770000
