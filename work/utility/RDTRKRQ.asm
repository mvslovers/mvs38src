.********************************************************************** 00001004
.*                                                                    * 00002004
.* MACRO NAME  : RDTRKRQ                                              * 00003004
.* AUTHOR      : DAVE KREISS                                          * 00004004
.* FUNCTIONS   : INTERFACE TO READ TRACK API                          * 00005006
.*                                                                    * 00006004
.********************************************************************** 00007004
.*                                                                    * 00007104
.*        FUNCT=   OPEN, READ OR CLOSE                                * 00008104
.*                 OPEN REQUIRES WORK=, DDNAME=, PARM= AND EPA=       * 00008204
.*                 READ REQUIRES WORK=, CCHH=, PARM= AND EPA=         * 00008404
.*                 CLOSE REQUIRES WORK=, PARM= AND EPA=               * 00008504
.*        DDNAME=  ADDRESS OF 8 CHARACTER DDNAME ALLOCATED TO         * 00008804
.*                 THE VOLUME CONTAINING THE TRACK(S) TO BE READ.     * 00008904
.*        WORK=    ADDRESS OF WORK AREA DEFINED IN RDTRKWA MACRO      * 00009004
.*        CCHH=    ADDRESS OF 4 BYTE CCHH OF TRACK TO READ            * 00009104
.*        EPA=     ADDRESS OF WORD CONTAINING THE EPA OF RDTRK.       * 00010004
.*                 OPEN FILLS IN THIS AND CLOSE CLEARS THIS FIELD.    * 00011304
.*        PARM=    ADDRESS OF FOUR WORDS USED TO BUILD PARAMETERS.    * 00011404
.*                                                                    * 00011504
.********************************************************************** 00011604
.* CHANGE LOG:                                                        * 00011704
.* MM/DD/YY AAA V.VV DESCRIPTION                                      * 00011804
.* 04/03/20 DSK 1.01 CREATED                                          * 00011904
.* 01/30/22 DSK 1.02 ADD DELETE OF READ TRACK API IN CLOSE            * 00012006
.********************************************************************** 00012104
         MACRO                                                          00013004
         RDTRKRQ &FUNCT,&WORK=,&CCHH=,&DDNAME=,&PARM=,&EPA=             00020000
         AIF   (T'&FUNCT EQ 'O').FUNERR                                 00030000
         AIF   ('&FUNCT' EQ 'OPEN').FUNOK                               00040000
         AIF   ('&FUNCT' EQ 'READ').FUNOK                               00050000
         AIF   ('&FUNCT' EQ 'CLOSE').FUNOK                              00060000
.FUNERR  ANOP                                                           00070000
         MNOTE 8,'FUNCTION INVALID'                                     00080000
         MEXIT                                                          00090000
.FUNOK   ANOP                                                           00100000
         AIF   (T'&WORK NE 'O').WRKOK                                   00110000
         MNOTE 8,'WORK= REQUIRED'                                       00120000
         MEXIT                                                          00130000
.WRKOK   ANOP                                                           00140000
         AIF   ('&FUNCT' EQ 'CLOSE').CCHHOK                             00150000
         AIF   (T'&CCHH NE 'O').CCHHOK                                  00160000
         MNOTE 8,'WORK= REQUIRED'                                       00170000
         MEXIT                                                          00180000
.CCHHOK  ANOP                                                           00190000
         AIF   ('&FUNCT' EQ 'CLOSE').DDNOK                              00200000
         AIF   ('&FUNCT' EQ 'READ').DDNOK                               00210000
         AIF   (T'&DDNAME NE 'O').DDNOK                                 00220001
         MNOTE 8,'DDNAME= REQUIRED'                                     00230000
         MEXIT                                                          00240000
.DDNOK   ANOP                                                           00250000
         AIF   (T'&PARM NE 'O').PARMOK                                  00260000
         MNOTE 8,'PARM= REQUIRED'                                       00270000
         MEXIT                                                          00280000
.PARMOK  ANOP                                                           00290000
         AIF   (T'&EPA NE 'O').EPAOK                                    00300000
         MNOTE 8,'EPA= REQUIRED'                                        00310000
         MEXIT                                                          00320000
.EPAOK   ANOP                                                           00330000
         LA    R0,=C'&FUNCT'           FUNCTION ADDRESS                 00340003
         ST    R0,&PARM+0*4            SAVE FUNCTION ADDRESS            00350003
         LA    R0,&WORK                WORKAREA ADDRESS                 00360003
         ST    R0,&PARM+1*4            SAVE WORKAREA ADDRESS            00370003
         AIF   ('&FUNCT' EQ 'CLOSE').PRMDON                             00380000
         LA    R0,&CCHH                CCHH ADDRESS                     00390003
         ST    R0,&PARM+2*4            SAVE CCHH ADDRESS                00400003
         AIF   ('&FUNCT' EQ 'READ').PRMDON                              00410002
         LA    R0,&DDNAME              DDNAME ADDRESS                   00420003
         ST    R0,&PARM+3*4            SAVE DDNAME ADDRESS              00430003
.PRMDON  ANOP                                                           00440000
         AIF   ('&FUNCT' NE 'OPEN').CALL                                00450000
*        LOAD  EPLOC==CL8'RDTRK'       LOAD RDTRK                       00460003
         LOAD  EPLOC==CL8'RDTRK'       LOAD RDTRK                       00470003
         ST    R0,&EPA                 SAVE EPA                         00480003
.CALL    ANOP                                                           00490000
         LA    R1,&PARM                PARAMETERS AREA                  00500003
         L     R15,&EPA                GET RDTRK ADDRESS                00510003
         BALR  R14,R15                 CALL RDTRK                       00520004
         AIF   ('&FUNCT' NE 'CLOSE').DONE                               00521004
         STM   R15,R1,16(R13)          SAVE CLOSE R15-R1                00522005
*        DELETE EPLOC==CL8'RDTRK'      DELETE RDTRK                     00523004
         DELETE EPLOC==CL8'RDTRK'      DELETE RDTRK                     00523104
         XC    &EPA,&EPA               CLEAR EPA                        00523204
         LM    R15,R1,16(R13)          RESTORE CLOSE R15-R1             00524004
.DONE    ANOP                                                           00525005
         MEND                                                           00530000
