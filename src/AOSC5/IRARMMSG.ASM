         TITLE 'IRARMMSG - SYSTEM RESOURCES MANAGER MESSAGE MODULE'     01300002
*********************************************************************** 01600002
*                                                                     * 02000002
*        .    NAME                                                    * 03000002
*                                                                     * 04000002
*             ASSEMBLY MODULE NAME - IRARMMSG                         * 05000002
*             COMMON NAME - SYSTEM RESOURCES MANAGER MESSAGE MODULE   * 06000002
*             LOAD MODULE NAME - SYSTEM NUCLEUS                       * 07000002
*             ALIASES - NONE                                          * 08000002
*             CSECT - IRARMMSG                                        * 09000002
*                                                                     * 10000002
*        .    FUNCTION                                                * 11000002
*                                                                     * 12000002
*             IRARMMSG IS A NON- EXECUTABLE MODULE CONTAINING THE     * 13000002
*             WTO LIST MACRO FORMS OF SYSTEM RESOURCES MANAGER        * 14000002
*             MESSAGES                                                * 14500002
*                                                                     * 15000002
*        .    ATTRIBUTES                                              * 16000002
*                                                                     * 17000002
*             PROTECT KEY 0                                           * 18000002
*             REFRESHABLE                                             * 19000002
*             NON-EXECUTABLE                                          * 20000002
*             RESIDENT NUCLEUS                                        * 21000002
*                                                                     * 22000002
*********************************************************************** 23000002
*                                                                       24000002
*                                                                       25000002
IRARMMSG CSECT                                                          26000002
* A-000000-999999                                               @Y02133 26500002
*                                                                       27000002
*                                                                       28000002
*        ENTRY POINTS:                                                  29000002
*                                                                       30000002
         ENTRY IRARM100 -          MESSAGE IRA100I                      31000002
         ENTRY IRARM101 -          MESSAGE IRA101I                      32000002
         ENTRY IRARM102 -          MESSAGE IRA102I                      33000002
         ENTRY IRARM200 -          MESSAGE IRA200I                      34000002
         ENTRY IRARM201 -          MESSAGE IRA201I                      35000002
         ENTRY IRARM202 -          MESSAGE IRA202I                      36000002
         ENTRY IRARM203 -          MESSAGE IRA203I             @ZM43072 36005040
         ENTRY IRARM400 -          MESSAGE IRA400I             @Z40BPRH 36010040
         ENTRY IRARM401 -          MESSAGE IRA401I             @Z40BPRH 36020040
         ENTRY IRARM402 -          MESSAGE IRA402I             @Z40BPRH 36030040
         ENTRY IRARM403 -          MESSAGE IRA403I             @ZM43072 36080040
         ENTRY IRARM500                                         DSK1083 36081010
         ENTRY IRARM501                                         DSK1083 36081020
*                                                                       37000002
*                                                                       38000002
         EJECT                                                          39000002
*                                                                       40000002
*        SYSTEM QUEUE SPACE SHORTAGE MESSAGES ISSUED BY STORAGE         41000002
*        MANAGEMENT ENTRY IRARMSQA, SQA SHORTAGE MESSAGE WRITER         42000002
*                                                                       43000002
*                                                                       44000002
IRARM100 WTO   'IRA100I SQA SHORTAGE',                                 C45000040
               ROUTCDE=(2),DESC=4,MF=L                         @Z40BPSS 46000040
         DC    0F'0'                                            DSK1083 46000050
         SPACE 2                                                        47000002
IRARM101 WTO   'IRA101I CRITICAL SQA SHORTAGE',                        C48000040
               ROUTCDE=(2),DESC=4,MF=L                         @Z40BPSS 49000040
         DC    X'70214C'                     !!! SOURCE COMPARE FIX !!! 49000050
         DC    0F'0'                                            DSK1083 49000050
         SPACE 2                                                        50000002
IRARM102 WTO   'IRA102I SQA SHORTAGE RELIEVED',                        C51000040
               ROUTCDE=(2),DESC=4,MF=L                         @Z40BPSS 52000040
         DC    X'645870'                     !!! SOURCE COMPARE FIX !!! 52000050
         DC    0F'0'                                            DSK1083 52000050
*                                                                       53000002
         EJECT                                                          54000002
*                                                                       55000002
*        AUXILIARY STORAGE SHORTAGE MESSAGES ISSUED BY STORAGE          56000002
*        MANAGEMENT ENTRY IRARMASM, AUXILIARY STORAGE MONITORING        57000002
*                                                                       58000002
*                                                                       59000002
IRARM200 WTO   'IRA200I AUXILIARY STORAGE SHORTAGE',                   C60000002
               ROUTCDE=(2),DESC=4,MF=L                                  61000002
         DC    X'4770'                       !!! SOURCE COMPARE FIX !!! 61000010
         DC    0F'0'                                            DSK1083 61000010
         SPACE 2                                                        62000002
IRARM201 WTO   'IRA201I CRITICAL AUXILIARY STORAGE SHORTAGE',          C63000002
               ROUTCDE=(2),DESC=4,MF=L                                  64000002
         DC    X'58'                         !!! SOURCE COMPARE FIX !!! 64000010
         DC    0F'0'                                            DSK1083 64000010
         SPACE 2                                                        65000002
IRARM202 WTO   'IRA202I AUXILIARY STORAGE SHORTAGE RELIEVED',          C66000002
               ROUTCDE=(2),DESC=4,MF=L                                  67000002
         DC    X'5A'                         !!! SOURCE COMPARE FIX !!! 67000010
         DC    0F'0'                                            DSK1083 67000010
         SPACE 2                                                        67000540
IRARM203 WTO   'IRA203I NN% AUXILIARY STORAGE ALLOCATED TO XXXXXXXX',  C67001040
               ROUTCDE=(2),DESC=4,MF=L                         @ZM43072 67001540
         DC    X'8B'                         !!! SOURCE COMPARE FIX !!! 67001550
         DC    0F'0'                                            DSK1083 67001550
*                                                                       67002040
         EJECT                                                          67004040
*                                                              @Z40BPRH 67006040
*                                                              @Z40BPRH 67008040
*        REAL STORAGE SHORTAGE MESSAGES ISSUED BY STORAGE      @Z40BPRH 67010040
*        MANAGEMENT ENTRY IRARMMS2, REAL STORAGE MONITORING    @Z40BPRH 67012040
*                                                              @Z40BPRH 67014040
*                                                              @Z40BPRH 67016040
IRARM400 WTO   'IRA400I PAGEABLE STORAGE SHORTAGE',                    C67018040
               ROUTCDE=(2),DESC=4,MF=L                         @Z40BPRH 67020040
         DC    X'FE5850'                     !!! SOURCE COMPARE FIX !!! 67020050
         DC    0F'0'                                            DSK1083 67020050
         SPACE 2                                                        67022040
IRARM401 WTO   'IRA401I CRITICAL PAGEABLE STORAGE SHORTAGE',           C67024040
               ROUTCDE=(2),DESC=4,MF=L                         @Z40BPRH 67026040
         DC    X'4770'                       !!! SOURCE COMPARE FIX !!! 67026050
         DC    0F'0'                                            DSK1083 67026050
         SPACE 2                                                        67028040
IRARM402 WTO   'IRA402I PAGEABLE STORAGE SHORTAGE RELIEVED',           C67030040
               ROUTCDE=(2),DESC=4,MF=L                         @Z40BPRH 67080040
         DC    X'19BA'                       !!! SOURCE COMPARE FIX !!! 67080050
         DC    0F'0'                                            DSK1083 67080050
         SPACE 2                                                        67130040
IRARM403 WTO   'IRA403I XXXXXXXX SWAPPED TO RECLAIM REAL STORAGE; XXXXXC67180040
                PAGES XXXXX FIXED',                             DSK1083C67181010
               ROUTCDE=(2),DESC=4,MF=L                         @ZM43072 67230040
         DC    X'181311'                     !!! SOURCE COMPARE FIX !!! 67230050
         DC    0F'0'                                            DSK1083 67230050
IRARM500 WTO   'IRA500I SWAP IN FAILED DUE TO FIXED STORAGE REQUIRED FOC67240020
               R USER XXXXXXXX - YYYYY PAGES',                  DSK1083C67240030
               ROUTCDE=(2),DESC=4,MF=L                          DSK1083 67240040
         DC    0F'0'                                            DSK1083 67240050
IRARM501 WTO   'IRA501I XXXXXXXX NOW SWAPPED IN',               DSK1083C67240060
               ROUTCDE=(2),DESC=4,MF=L                          DSK1083 67240070
         END   ,                                                DSK1083 68000002
