*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=* 00000010
*=                                                                   =* 00000020
*=                                                                   =* 00000030
*=                                                                   =* 00000040
*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=* 00000050
HASPFMT4 CSECT                                                          00000060
         DC    CL1'-'                                                   00000070
         DC    XL1'24'                                                  00000080
         DC    CL32'HASP PROCESSOR CONTROL ELEMENT ('                   00000090
         DC    CL5'PCE) '                                               00000100
         DC    XL1'16'                                                  00000110
         DC    CL23'CURRENT PROCESSOR PCE C'                            00000120
         DC    XL1'01'                                                  00000130
         DC    CL8'PCE     '                                            00000140
         DC    F'01196'                                                 00000150
         DC    CL1' '                                                   00000160
         DC    XL1'1C'                                                  00000170
         DC    CL29'COMMUNICATION PROCESSOR PCE C'                      00000180
         DC    XL1'01'                                                  00000190
         DC    CL8'PCE     '                                            00000200
         DC    F'01128'                                                 00000210
         DC    CL1' '                                                   00000220
         DC    XL1'1C'                                                  00000230
         DC    CL29'PROCESS SYSOUT PROCESSOR PCEC'                      00000240
         DC    XL1'01'                                                  00000250
         DC    CL8'PCE     '                                            00000260
         DC    XL3'000004'                                              00000270
         DC    CL2'% '                                                  00000280
         DC    XL1'18'                                                  00000290
         DC    CL25'EXECUTION PROCESSOR PCE C'                          00000300
         DC    XL1'01'                                                  00000310
         DC    CL8'PCE     '                                            00000320
         DC    F'01136'                                                 00000330
         DC    CL1' '                                                   00000340
         DC    XL1'1C'                                                  00000350
         DC    CL29'JCL CONVERSION PROCESSOR PCEC'                      00000360
         DC    XL1'01'                                                  00000370
         DC    CL8'PCE     '                                            00000380
         DC    F'01140'                                                 00000390
         DC    CL1' '                                                   00000400
         DC    XL1'1A'                                                  00000410
         DC    CL27'ASYNCHRONOUS PROCESSOR PCEC'                        00000420
         DC    XL1'01'                                                  00000430
         DC    CL8'PCE     '                                            00000440
         DC    H'0'                                                     00000450
         DC    H'1144'                                                  00000460
         DC    CL1' '                                                   00000470
         DC    XL1'1C'                                                  00000480
         DC    CL29'TIME EXCESSION PROCESSOR PCEC'                      00000490
         DC    XL1'01'                                                  00000500
         DC    CL8'PCE     '                                            00000510
         DC    H'0'                                                     00000520
         DC    XL1'04'                                                  00000530
         DC    CL2'@ '                                                  00000540
         DC    XL1'14'                                                  00000550
         DC    CL21'TIMER PROCESSOR PCE C'                              00000560
         DC    XL1'01'                                                  00000570
         DC    CL8'PCE     '                                            00000580
         DC    H'0'                                                     00000590
         DC    H'1152'                                                  00000600
         DC    CL1' '                                                   00000610
         DC    XL1'10'                                                  00000620
         DC    CL17'LINE MANAGER PCEC'                                  00000630
         DC    XL1'01'                                                  00000640
         DC    CL8'PCE     '                                            00000650
         DC    H'0'                                                     00000660
         DC    XL1'04'                                                  00000670
         DC    CL2'h '                                                  00000680
         DC    XL1'1C'                                                  00000690
         DC    CL29'REMOTE CONSOLE PROCESSOR PCEC'                      00000700
         DC    XL1'01'                                                  00000710
         DC    CL8'PCE     '                                            00000720
         DC    H'0'                                                     00000730
         DC    H'1164'                                                  00000740
         DC    CL1' '                                                   00000750
         DC    XL1'14'                                                  00000760
         DC    CL21'OUTPUT PROCESSOR PCEC'                              00000770
         DC    XL1'01'                                                  00000780
         DC    CL8'PCE     '                                            00000790
         DC    H'0'                                                     00000800
         DC    H'1168'                                                  00000810
         DC    CL1' '                                                   00000820
         DC    XL1'18'                                                  00000830
         DC    CL25'HOLD QUEUE PROCESSOR PCEC'                          00000840
         DC    XL1'01'                                                  00000850
         DC    CL8'PCE     '                                            00000860
         DC    H'0'                                                     00000870
         DC    XL1'04'                                                  00000880
         DC    CL2'm '                                                  00000890
         DC    XL1'14'                                                  00000900
         DC    CL21'PURGE PROCESSOR PCE C'                              00000910
         DC    XL1'01'                                                  00000920
         DC    CL8'PCE     '                                            00000930
         DC    H'0'                                                     00000940
         DC    XL1'04'                                                  00000950
         DC    CL2'q '                                                  00000960
         DC    XL1'18'                                                  00000970
         DC    CL25'WARMSTART PROCESSOR PCE C'                          00000980
         DC    XL1'01'                                                  00000990
         DC    CL8'PCE     '                                            00001000
         DC    H'0'                                                     00001010
         DC    H'1180'                                                  00001020
         DC    CL1' '                                                   00001030
         DC    XL1'18'                                                  00001040
         DC    CL25'CHECKPOINT PROCESSOR PCEC'                          00001050
         DC    XL1'01'                                                  00001060
         DC    CL8'PCE     '                                            00001070
         DC    H'0'                                                     00001080
         DC    H'1184'                                                  00001090
         DC    CL1' '                                                   00001100
         DC    XL1'1C'                                                  00001110
         DC    CL29'PRIORITY AGING PROCESSOR PCEC'                      00001120
         DC    XL1'01'                                                  00001130
         DC    CL8'PCE     '                                            00001140
         DC    H'0'                                                     00001150
         DC    XL1'04'                                                  00001160
         DC    CL1'u'                                                   00001170
         DC    H'4096'                                                  00001180
         DC    CL8'PCESAVEA'                                            00001190
         DC    F'00004'                                                 00001200
         DC    H'0'                                                     00001210
         DC    CL8'PCEPREV '                                            00001220
         DC    H'0004'                                                  00001230
         DC    XL4'00040000'                                            00001240
         DC    CL8'PCENEXT '                                            00001250
         DC    XL4'00080004'                                            00001260
         DC    H'0'                                                     00001270
         DC    CL8'PCELINK '                                            00001280
         DC    H'0012'                                                  00001290
         DC    XL4'00040000'                                            00001300
         DC    CL8'PCER15  '                                            00001310
         DC    XL4'00100004'                                            00001320
         DC    H'0'                                                     00001330
         DC    CL8'PCER0   '                                            00001340
         DC    H'0020'                                                  00001350
         DC    XL4'00040000'                                            00001360
         DC    CL8'PCER1   '                                            00001370
         DC    XL4'00180004'                                            00001380
         DC    H'0'                                                     00001390
         DC    CL8'PCEWA   '                                            00001400
         DC    H'0028'                                                  00001410
         DC    XL4'00040000'                                            00001420
         DC    CL8'PCEWB   '                                            00001430
         DC    XL4'00200004'                                            00001440
         DC    H'0'                                                     00001450
         DC    CL8'PCEWC   '                                            00001460
         DC    H'0036'                                                  00001470
         DC    XL4'00040000'                                            00001480
         DC    CL8'PCEWD   '                                            00001490
         DC    XL4'00280004'                                            00001500
         DC    H'0'                                                     00001510
         DC    CL8'PCEWE   '                                            00001520
         DC    H'0044'                                                  00001530
         DC    XL4'00040000'                                            00001540
         DC    CL8'PCEWF   '                                            00001550
         DC    XL4'00300004'                                            00001560
         DC    H'0'                                                     00001570
         DC    CL8'PCEBASE3'                                            00001580
         DC    H'0052'                                                  00001590
         DC    XL4'00040000'                                            00001600
         DC    CL8'PCER9   '                                            00001610
         DC    XL4'00380004'                                            00001620
         DC    H'0'                                                     00001630
         DC    CL8'PCEJCT  '                                            00001640
         DC    H'0060'                                                  00001650
         DC    XL4'00040000'                                            00001660
         DC    CL8'PCEBASE1'                                            00001670
         DC    XL1'00'                                                  00001680
         DC    CL1' '                                                   00001690
         DC    H'0004'                                                  00001700
         DC    H'0'                                                     00001710
         DC    CL8'PCEBASE2'                                            00001720
         DC    H'0068'                                                  00001730
         DC    XL4'00040000'                                            00001740
         DC    CL8'PCEPCEA '                                            00001750
         DC    XL4'00480004'                                            00001760
         DC    H'0'                                                     00001770
         DC    CL8'PCEPCEB '                                            00001780
         DC    XL1'00'                                                  00001790
         DC    CL1'<'                                                   00001800
         DC    XL4'00040000'                                            00001810
         DC    CL8'PCEEWF  '                                            00001820
         DC    XL1'00'                                                  00001830
         DC    CL1'&&'                                                  00001840
         DC    H'0002'                                                  00001850
         DC    H'0'                                                     00001860
         DC    CL8'PCEID   '                                            00001870
         DC    H'0082'                                                  00001880
         DC    XL4'00020000'                                            00001890
         DC    CL8'PCEDADCT'                                            00001900
         DC    XL4'00540008'                                            00001910
         DC    H'0'                                                     00001920
         DC    CL8'PCEBUFAD'                                            00001930
         DC    H'0088'                                                  00001940
         DC    XL4'00040000'                                            00001950
         DC    CL8'PCESEEK '                                            00001960
         DC    XL1'00'                                                  00001970
         DC    CL1'*'                                                   00001980
         DC    H'0004'                                                  00001990
         DC    H'0'                                                     00002000
         DC    CL8'PCEIOEWF'                                            00002010
         DC    XL1'00'                                                  00002020
         DC    CL1'-'                                                   00002030
         DC    XL4'00040000'                                            00002040
         DC    CL8'PCEBUFCT'                                            00002050
         DC    XL4'00640001'                                            00002060
         DC    H'0'                                                     00002070
         DC    CL8'PCEDEVTP'                                            00002080
         DC    H'0101'                                                  00002090
         DC    F'65536'                                                 00002100
         DC    CL8'PCEDCT  '                                            00002110
         DC    XL4'00680004'                                            00002120
         DC    H'0'                                                     00002130
         DC    CL8'PCEJQE  '                                            00002140
         DC    XL1'00'                                                  00002150
         DC    CL1'%'                                                   00002160
         DC    XL4'00040000'                                            00002170
         DC    CL8'PCEWORK '                                            00002180
         DC    XL3'007001'                                              00002190
         DC    CL1' '                                                   00002200
         DC    XL4'FFFFFFFF'                                            00002210
R0       EQU   0                                                        00002220
R1       EQU   1                                                        00002230
R2       EQU   2                                                        00002240
R3       EQU   3                                                        00002250
R4       EQU   4                                                        00002260
R5       EQU   5                                                        00002270
R6       EQU   6                                                        00002280
R7       EQU   7                                                        00002290
R8       EQU   8                                                        00002300
R9       EQU   9                                                        00002310
R10      EQU   10                                                       00002320
R11      EQU   11                                                       00002330
R12      EQU   12                                                       00002340
R13      EQU   13                                                       00002350
R14      EQU   14                                                       00002360
R15      EQU   15                                                       00002370
         END                                                            00002380
