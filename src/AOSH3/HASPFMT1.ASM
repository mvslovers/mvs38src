*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=* 00000010
*=                                                                   =* 00000020
*=                                                                   =* 00000030
*=                                                                   =* 00000040
*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=* 00000050
HASPFMT1 CSECT                                                          00000060
         DC    CL1'B'                                                   00000070
         DC    XL1'00'                                                  00000080
         DC    CL8'SSVT    '                                            00000090
         DC    H'0'                                                     00000100
         DC    CL1'-'                                                   00000110
         DC    XL1'22'                                                  00000120
         DC    CL32'HASP SUBSYSTEM VECTOR TABLE (SSV'                   00000130
         DC    CL2'T)'                                                  00000140
         DC    H'4096'                                                  00000150
         DC    CL8'SSVTRSV1'                                            00000160
         DC    H'0'                                                     00000170
         DC    XL4'00020000'                                            00000180
         DC    CL8'SSVTFNUM'                                            00000190
         DC    XL4'00020002'                                            00000200
         DC    CL1' '                                                   00000210
         DC    XL1'1E'                                                  00000220
         DC    CL30'HASP SUPPORTED FUNCTION MATRIX'                     00000230
         DC    H'4096'                                                  00000240
         DC    CL8'SSVTFCOD'                                            00000250
         DC    H'0004'                                                  00000260
         DC    H'0256'                                                  00000270
         DC    CL1' '                                                   00000280
         DC    XL1'20'                                                  00000290
         DC    CL32'HASP SUPPORTED FUNCTION POINTERS'                   00000300
         DC    H'4096'                                                  00000310
         DC    CL8'$SVSOUT '                                            00000320
         DC    H'0260'                                                  00000330
         DC    XL4'00040000'                                            00000340
         DC    CL8'$SVCANC '                                            00000350
         DC    XL4'01080004'                                            00000360
         DC    H'0'                                                     00000370
         DC    CL8'$SVSTAT '                                            00000380
         DC    H'0268'                                                  00000390
         DC    XL4'00040000'                                            00000400
         DC    CL8'$SVEOT  '                                            00000410
         DC    XL4'01100004'                                            00000420
         DC    H'0'                                                     00000430
         DC    CL8'$SVJBSL '                                            00000440
         DC    H'0276'                                                  00000450
         DC    XL4'00040000'                                            00000460
         DC    CL8'$SVALOC '                                            00000470
         DC    XL4'01180004'                                            00000480
         DC    H'0'                                                     00000490
         DC    CL8'$SVUNAL '                                            00000500
         DC    H'0284'                                                  00000510
         DC    XL4'00040000'                                            00000520
         DC    CL8'$SVEOM  '                                            00000530
         DC    XL4'01200004'                                            00000540
         DC    H'0'                                                     00000550
         DC    CL8'$SVWTO  '                                            00000560
         DC    H'0292'                                                  00000570
         DC    XL4'00040000'                                            00000580
         DC    CL8'$SVCMND '                                            00000590
         DC    XL4'01280004'                                            00000600
         DC    H'0'                                                     00000610
         DC    CL8'$SVUSER '                                            00000620
         DC    H'0300'                                                  00000630
         DC    XL4'00040000'                                            00000640
         DC    CL8'$SVTERM '                                            00000650
         DC    XL4'01300004'                                            00000660
         DC    H'0'                                                     00000670
         DC    CL8'$SVRENQ '                                            00000680
         DC    H'0308'                                                  00000690
         DC    XL4'00040000'                                            00000700
         DC    CL8'$SVOPEN '                                            00000710
         DC    XL4'01380004'                                            00000720
         DC    H'0'                                                     00000730
         DC    CL8'$SVCLOS '                                            00000740
         DC    H'0316'                                                  00000750
         DC    XL4'00040000'                                            00000760
         DC    CL8'$SVCKPT '                                            00000770
         DC    XL1'01'                                                  00000780
         DC    CL1' '                                                   00000790
         DC    H'0004'                                                  00000800
         DC    H'0'                                                     00000810
         DC    CL8'$SVREST '                                            00000820
         DC    H'0324'                                                  00000830
         DC    XL4'00040000'                                            00000840
         DC    CL8'$SVREQID'                                            00000850
         DC    XL4'01480004'                                            00000860
         DC    H'0'                                                     00000870
         DC    CL8'$SVRETID'                                            00000880
         DC    XL1'01'                                                  00000890
         DC    CL1'<'                                                   00000900
         DC    H'0004'                                                  00000910
         DC    CL1' '                                                   00000920
         DC    XL1'10'                                                  00000930
         DC    CL16'HASP EXTENSIONS '                                   00000940
         DC    H'4096'                                                  00000950
         DC    CL8'$SVPOST '                                            00000960
         DC    XL1'01'                                                  00000970
         DC    CL1'&&'                                                  00000980
         DC    XL4'00040000'                                            00000990
         DC    CL8'$SVDEST '                                            00001000
         DC    XL4'01540004'                                            00001010
         DC    H'0'                                                     00001020
         DC    CL8'$SVCOPN '                                            00001030
         DC    H'0344'                                                  00001040
         DC    XL4'00040000'                                            00001050
         DC    CL8'$SVCCLS '                                            00001060
         DC    XL1'01'                                                  00001070
         DC    CL1'*'                                                   00001080
         DC    H'0004'                                                  00001090
         DC    H'0'                                                     00001100
         DC    CL8'$SVGCELL'                                            00001110
         DC    XL1'01'                                                  00001120
         DC    CL1'-'                                                   00001130
         DC    XL4'00040000'                                            00001140
         DC    CL8'$SVGCPOL'                                            00001150
         DC    XL4'01640004'                                            00001160
         DC    H'0'                                                     00001170
         DC    CL8'$SVFCELL'                                            00001180
         DC    H'0360'                                                  00001190
         DC    XL4'00040000'                                            00001200
         DC    CL8'$SVFCELA'                                            00001210
         DC    XL1'01'                                                  00001220
         DC    CL1'%'                                                   00001230
         DC    H'0004'                                                  00001240
         DC    H'0'                                                     00001250
         DC    CL8'$SVGCMNS'                                            00001260
         DC    H'0368'                                                  00001270
         DC    XL4'00040000'                                            00001280
         DC    CL8'$SVVFL  '                                            00001290
         DC    XL4'01740004'                                            00001300
         DC    H'0'                                                     00001310
         DC    CL8'$SMPATCH'                                            00001320
         DC    H'0376'                                                  00001330
         DC    H'0004'                                                  00001340
         DC    CL1' '                                                   00001350
         DC    XL1'1C'                                                  00001360
         DC    CL28'COMMUNICATION CONTROL FIELDS'                       00001370
         DC    H'4096'                                                  00001380
         DC    CL8'$SVHCT  '                                            00001390
         DC    XL1'01'                                                  00001400
         DC    CL1'@'                                                   00001410
         DC    XL4'00040000'                                            00001420
         DC    CL8'$SVSSCT '                                            00001430
         DC    XL4'01800004'                                            00001440
         DC    H'0'                                                     00001450
         DC    CL8'$SVHAVT '                                            00001460
         DC    XL1'01'                                                  00001470
         DC    CL1'd'                                                   00001480
         DC    XL4'00040000'                                            00001490
         DC    CL8'$SVPIDLE'                                            00001500
         DC    XL1'01'                                                  00001510
         DC    CL1'h'                                                   00001520
         DC    H'0004'                                                  00001530
         DC    H'0'                                                     00001540
         DC    CL8'$SVOUTXS'                                            00001550
         DC    H'0396'                                                  00001560
         DC    XL4'00040000'                                            00001570
         DC    CL8'$SVHASP '                                            00001580
         DC    XL4'01900004'                                            00001590
         DC    H'0'                                                     00001600
         DC    CL8'$SVSTUS '                                            00001610
         DC    XL1'01'                                                  00001620
         DC    CL1'm'                                                   00001630
         DC    F'65536'                                                 00001640
         DC    CL8'$SVVARF '                                            00001650
         DC    XL1'01'                                                  00001660
         DC    CL1'n'                                                   00001670
         DC    H'0001'                                                  00001680
         DC    H'0'                                                     00001690
         DC    CL8'$SVTSLOK'                                            00001700
         DC    XL1'01'                                                  00001710
         DC    CL1'o'                                                   00001720
         DC    F'65792'                                                 00001730
         DC    CL8'$SVCOMCH'                                            00001740
         DC    XL1'01'                                                  00001750
         DC    CL1'p'                                                   00001760
         DC    H'0001'                                                  00001770
         DC    H'0256'                                                  00001780
         DC    CL8'$SVRELNO'                                            00001790
         DC    XL1'01'                                                  00001800
         DC    CL1'q'                                                   00001810
         DC    XL4'00020100'                                            00001820
         DC    CL8'$SVLEVEL'                                            00001830
         DC    XL4'019A0002'                                            00001840
         DC    H'0256'                                                  00001850
         DC    CL8'$SVSID  '                                            00001860
         DC    H'0412'                                                  00001870
         DC    XL4'00040000'                                            00001880
         DC    CL8'$SVTOQUL'                                            00001890
         DC    XL4'01A10001'                                            00001900
         DC    H'0'                                                     00001910
         DC    CL8'$SVNOUNT'                                            00001920
         DC    XL1'01'                                                  00001930
         DC    CL1'u'                                                   00001940
         DC    XL4'00020000'                                            00001950
         DC    CL8'$SVROUT '                                            00001960
         DC    XL1'01'                                                  00001970
         DC    CL1'w'                                                   00001980
         DC    H'0002'                                                  00001990
         DC    H'0'                                                     00002000
         DC    CL8'$SVROUTM'                                            00002010
         DC    XL1'01'                                                  00002020
         DC    CL1'y'                                                   00002030
         DC    XL4'01000000'                                            00002040
         DC    CL8'$SVRDT  '                                            00002050
         DC    XL1'02'                                                  00002060
         DC    CL1'y'                                                   00002070
         DC    H'0004'                                                  00002080
         DC    H'0'                                                     00002090
         DC    CL8'$SVRDTE '                                            00002100
         DC    H'0684'                                                  00002110
         DC    XL4'00040000'                                            00002120
         DC    CL8'$SVIRDRS'                                            00002130
         DC    XL4'02B00004'                                            00002140
         DC    H'0'                                                     00002150
         DC    CL8'$SVIRWT '                                            00002160
         DC    H'0692'                                                  00002170
         DC    XL4'00040000'                                            00002180
         DC    CL8'$SVNINRS'                                            00002190
         DC    XL4'02B80002'                                            00002200
         DC    H'0'                                                     00002210
         DC    CL8'$SVMAXCL'                                            00002220
         DC    H'0698'                                                  00002230
         DC    H'0001'                                                  00002240
         DC    CL1' '                                                   00002250
         DC    XL1'18'                                                  00002260
         DC    CL24'CONSOLE SERVICE ELEMENTS'                           00002270
         DC    H'4096'                                                  00002280
         DC    CL8'$SVCMBA '                                            00002290
         DC    H'0700'                                                  00002300
         DC    XL4'00040000'                                            00002310
         DC    CL8'$SVCMBAC'                                            00002320
         DC    XL4'02C00004'                                            00002330
         DC    H'0'                                                     00002340
         DC    CL8'$SVCMBFQ'                                            00002350
         DC    XL1'02'                                                  00002360
         DC    CL1'H'                                                   00002370
         DC    XL4'00080000'                                            00002380
         DC    CL8'$SVCMBRQ'                                            00002390
         DC    XL4'02D00004'                                            00002400
         DC    H'0'                                                     00002410
         DC    CL8'$SVCOMMQ'                                            00002420
         DC    XL1'02'                                                  00002430
         DC    CL1'M'                                                   00002440
         DC    XL4'00040000'                                            00002450
         DC    CL8'$SVCOMCT'                                            00002460
         DC    XL1'02'                                                  00002470
         DC    CL1'Q'                                                   00002480
         DC    H'0004'                                                  00002490
         DC    CL1' '                                                   00002500
         DC    XL1'2C'                                                  00002510
         DC    CL32'$$POST ELEMENTS -- REQUESTS FOR '                   00002520
         DC    CL12'PCE SERVICE '                                       00002530
         DC    H'4096'                                                  00002540
         DC    CL8'$SVECF  '                                            00002550
         DC    XL4'02DC0004'                                            00002560
         DC    H'0'                                                     00002570
         DC    CL8'$SVCOMM '                                            00002580
         DC    H'0736'                                                  00002590
         DC    XL4'00040000'                                            00002600
         DC    CL8'$SVPSO  '                                            00002610
         DC    XL1'02'                                                  00002620
         DC    CL1'U'                                                   00002630
         DC    H'0004'                                                  00002640
         DC    H'0'                                                     00002650
         DC    CL8'$SVJOB  '                                            00002660
         DC    XL1'02'                                                  00002670
         DC    CL1'Y'                                                   00002680
         DC    XL4'00040000'                                            00002690
         DC    CL8'$SVCNV  '                                            00002700
         DC    XL4'02EC0004'                                            00002710
         DC    H'0'                                                     00002720
         DC    CL8'$SVASYNC'                                            00002730
         DC    XL1'02'                                                  00002740
         DC    CL1'0'                                                   00002750
         DC    XL4'00040000'                                            00002760
         DC    CL8'$SVXSTIM'                                            00002770
         DC    XL1'02'                                                  00002780
         DC    CL1'4'                                                   00002790
         DC    H'0004'                                                  00002800
         DC    H'0'                                                     00002810
         DC    CL8'$SVTIMER'                                            00002820
         DC    XL1'02'                                                  00002830
         DC    CL1'8'                                                   00002840
         DC    XL4'00040000'                                            00002850
         DC    CL8'$SVMLLM '                                            00002860
         DC    XL4'03000004'                                            00002870
         DC    H'0'                                                     00002880
         DC    CL8'$SVIRDR '                                            00002890
         DC    H'0772'                                                  00002900
         DC    H'0004'                                                  00002910
         DC    CL1' '                                                   00002920
         DC    XL1'1E'                                                  00002930
         DC    CL30'STORAGE CELL CONTROL ELEMENTS '                     00002940
         DC    H'4096'                                                  00002950
         DC    CL8'$SVCENQ '                                            00002960
         DC    XL4'0308000C'                                            00002970
         DC    H'0256'                                                  00002980
         DC    CL8'$SVQNAM '                                            00002990
         DC    H'0788'                                                  00003000
         DC    XL4'00080100'                                            00003010
         DC    CL8'$SVSSNM '                                            00003020
         DC    XL4'03180004'                                            00003030
         DC    H'0256'                                                  00003040
         DC    CL8'$SVCRNAM'                                            00003050
         DC    H'0796'                                                  00003060
         DC    XL4'00041000'                                            00003070
         DC    CL8'$SVCPOST'                                            00003080
         DC    XL4'0320000C'                                            00003090
         DC    H'0'                                                     00003100
         DC    CL8'$SVCTREQ'                                            00003110
         DC    H'0812'                                                  00003120
         DC    XL4'00040000'                                            00003130
         DC    CL8'$SVCELLS'                                            00003140
         DC    XL4'03300004'                                            00003150
         DC    H'0'                                                     00003160
         DC    CL8'$SVCELLF'                                            00003170
         DC    H'0820'                                                  00003180
         DC    H'0004'                                                  00003190
         DC    CL1' '                                                   00003200
         DC    XL1'26'                                                  00003210
         DC    CL32'HASP JOB SERVICES QUEUES LOCK EL'                   00003220
         DC    CL6'EMENT '                                              00003230
         DC    H'4352'                                                  00003240
         DC    CL8'$SVQLOKE'                                            00003250
         DC    XL4'03380004'                                            00003260
         DC    H'0'                                                     00003270
         DC    CL8'$SVQLOKC'                                            00003280
         DC    H'0828'                                                  00003290
         DC    XL4'00080000'                                            00003300
         DC    CL8'$SVQLOKP'                                            00003310
         DC    XL4'0344000C'                                            00003320
         DC    CL1' '                                                   00003330
         DC    XL1'12'                                                  00003340
         DC    CL18'HASP POST ELEMENT '                                 00003350
         DC    H'4096'                                                  00003360
         DC    CL8'$SVPOSTE'                                            00003370
         DC    XL1'03'                                                  00003380
         DC    CL1'&&'                                                  00003390
         DC    XL4'000C0000'                                            00003400
         DC    CL8'$SVPIT  '                                            00003410
         DC    XL1'03'                                                  00003420
         DC    CL1'*'                                                   00003430
         DC    H'0004'                                                  00003440
         DC    CL1' '                                                   00003450
         DC    XL1'12'                                                  00003460
         DC    CL18'JOB SERVICE QUEUES'                                 00003470
         DC    H'4096'                                                  00003480
         DC    CL8'$SVJLOCK'                                            00003490
         DC    XL1'03'                                                  00003500
         DC    CL1'-'                                                   00003510
         DC    XL4'00080000'                                            00003520
         DC    CL8'$SVJPCLS'                                            00003530
         DC    XL4'03680004'                                            00003540
         DC    H'0'                                                     00003550
         DC    CL8'$SVJPXBM'                                            00003560
         DC    XL1'03'                                                  00003570
         DC    CL1'%'                                                   00003580
         DC    XL4'00040000'                                            00003590
         DC    CL8'$SVJPNUM'                                            00003600
         DC    XL4'03700004'                                            00003610
         DC    H'0'                                                     00003620
         DC    CL8'$SVJXCLS'                                            00003630
         DC    H'0884'                                                  00003640
         DC    XL4'00040000'                                            00003650
         DC    CL8'$SVJXNUM'                                            00003660
         DC    XL4'03780004'                                            00003670
         DC    H'0'                                                     00003680
         DC    CL8'$SVJTERM'                                            00003690
         DC    XL1'03'                                                  00003700
         DC    CL1'@'                                                   00003710
         DC    XL4'00040000'                                            00003720
         DC    CL8'$SVJRENQ'                                            00003730
         DC    XL4'03800004'                                            00003740
         DC    CL1' '                                                   00003750
         DC    XL1'1C'                                                  00003760
         DC    CL28'MISCELLANEOUS SERVICE QUEUES'                       00003770
         DC    H'4096'                                                  00003780
         DC    CL8'$SVSPIOT'                                            00003790
         DC    XL1'03'                                                  00003800
         DC    CL1'd'                                                   00003810
         DC    H'0004'                                                  00003820
         DC    H'0'                                                     00003830
         DC    CL8'$SVTSCS '                                            00003840
         DC    XL1'03'                                                  00003850
         DC    CL1'h'                                                   00003860
         DC    XL4'00080000'                                            00003870
         DC    CL8'$SVPSOQ '                                            00003880
         DC    XL4'03900008'                                            00003890
         DC    H'0'                                                     00003900
         DC    CL8'$SVFIFOQ'                                            00003910
         DC    XL1'03'                                                  00003920
         DC    CL1'q'                                                   00003930
         DC    XL4'00040000'                                            00003940
         DC    CL8'$SVHOLDQ'                                            00003950
         DC    XL4'039C0004'                                            00003960
         DC    CL1' '                                                   00003970
         DC    XL1'16'                                                  00003980
         DC    CL22'SPOOL DATA MANAGEMENT '                             00003990
         DC    H'4096'                                                  00004000
         DC    CL8'$SVPDDB1'                                            00004010
         DC    H'0940'                                                  00004020
         DC    XL4'00040000'                                            00004030
         DC    CL8'$SVHQRCT'                                            00004040
         DC    XL4'03B00004'                                            00004050
         DC    H'0'                                                     00004060
         DC    CL8'$SVMAPL '                                            00004070
         DC    H'0948'                                                  00004080
         DC    XL4'00040000'                                            00004090
         DC    CL8'$SVXPRI '                                            00004100
         DC    XL4'03B80028'                                            00004110
         DC    H'4608'                                                  00004120
         DC    CL8'$SVNUMDA'                                            00004130
         DC    XL1'03'                                                  00004140
         DC    CL1'S'                                                   00004150
         DC    F'65536'                                                 00004160
         DC    CL8'$SVRINCR'                                            00004170
         DC    XL1'03'                                                  00004180
         DC    CL1'T'                                                   00004190
         DC    H'0001'                                                  00004200
         DC    H'0'                                                     00004210
         DC    CL8'$SVTKCEL'                                            00004220
         DC    XL1'03'                                                  00004230
         DC    CL1'U'                                                   00004240
         DC    F'65536'                                                 00004250
         DC    CL8'$SVBAKSP'                                            00004260
         DC    XL1'03'                                                  00004270
         DC    CL1'V'                                                   00004280
         DC    H'0001'                                                  00004290
         DC    H'0'                                                     00004300
         DC    CL8'$SVNTGBE'                                            00004310
         DC    XL1'03'                                                  00004320
         DC    CL1'W'                                                   00004330
         DC    F'65536'                                                 00004340
         DC    CL8'$SVTGALC'                                            00004350
         DC    XL1'03'                                                  00004360
         DC    CL1'Y'                                                   00004370
         DC    H'0004'                                                  00004380
         DC    H'0'                                                     00004390
         DC    CL8'$SVTGTOT'                                            00004400
         DC    H'1004'                                                  00004410
         DC    XL4'00040000'                                            00004420
         DC    CL8'$SVTTGBA'                                            00004430
         DC    XL1'03'                                                  00004440
         DC    CL1'0'                                                   00004450
         DC    H'0012'                                                  00004460
         DC    H'0'                                                     00004470
         DC    CL8'$SVTGASC'                                            00004480
         DC    H'1024'                                                  00004490
         DC    XL4'00040000'                                            00004500
         DC    CL8'$SVTGECB'                                            00004510
         DC    XL4'04040004'                                            00004520
         DC    H'0'                                                     00004530
         DC    CL8'$SVRPS  '                                            00004540
         DC    H'1032'                                                  00004550
         DC    H'0004'                                                  00004560
         DC    CL1' '                                                   00004570
         DC    XL1'1C'                                                  00004580
         DC    CL28'SYSOUT CLASS ATTRIBUTE TABLE'                       00004590
         DC    H'4096'                                                  00004600
         DC    CL8'$SVSCAT '                                            00004610
         DC    XL1'03'                                                  00004620
         DC    CL1'<'                                                   00004630
         DC    XL1'00'                                                  00004640
         DC    CL2'  '                                                  00004650
         DC    XL1'24'                                                  00004660
         DC    CL32'RETURN CONTROL ELEMENTS AND ROUT'                   00004670
         DC    CL4'INE '                                                00004680
         DC    H'4096'                                                  00004690
         DC    CL8'$SVSMFSO'                                            00004700
         DC    XL1'04'                                                  00004710
         DC    CL1'<'                                                   00004720
         DC    XL4'00040000'                                            00004730
         DC    CL8'$SVSMFJP'                                            00004740
         DC    XL1'04'                                                  00004750
         DC    CL1'&&'                                                  00004760
         DC    H'0004'                                                  00004770
         DC    H'0'                                                     00004780
         DC    CL8'$SVRETN '                                            00004790
         DC    H'1108'                                                  00004800
         DC    XL4'00020000'                                            00004810
         DC    CL8'$SVBR14 '                                            00004820
         DC    XL4'04560002'                                            00004830
         DC    CL1' '                                                   00004840
         DC    XL1'28'                                                  00004850
         DC    CL32'SPOOL DATA MANAGEMENT (VARIABLE '                   00004860
         DC    CL8'PORTION)'                                            00004870
         DC    H'4096'                                                  00004880
         DC    CL8'$SVTFRST'                                            00004890
         DC    XL4'04580004'                                            00004900
         DC    H'0'                                                     00004910
         DC    CL8'$SVTLAST'                                            00004920
         DC    XL1'04'                                                  00004930
         DC    CL1'*'                                                   00004940
         DC    XL4'00040000'                                            00004950
         DC    CL8'$SVTNEXT'                                            00004960
         DC    XL1'04'                                                  00004970
         DC    CL1'-'                                                   00004980
         DC    H'0004'                                                  00004990
         DC    H'0'                                                     00005000
         DC    CL8'$SVTED  '                                            00005010
         DC    H'1124'                                                  00005020
         DC    XL4'00040000'                                            00005030
         DC    CL8'$SVDCB  '                                            00005040
         DC    XL1'04'                                                  00005050
         DC    CL1' '                                                   00005060
         DC    H'0012'                                                  00005070
         DC    H'0'                                                     00005080
         DC    CL8'$SVDEB  '                                            00005090
         DC    H'1140'                                                  00005100
         DC    XL4'0004FFFF'                                            00005110
         DC    XL4'FFFF0000'                                            00005120
         DC    F'0'                                                     00005130
R0       EQU   0                                                        00005140
R1       EQU   1                                                        00005150
R2       EQU   2                                                        00005160
R3       EQU   3                                                        00005170
R4       EQU   4                                                        00005180
R5       EQU   5                                                        00005190
R6       EQU   6                                                        00005200
R7       EQU   7                                                        00005210
R8       EQU   8                                                        00005220
R9       EQU   9                                                        00005230
R10      EQU   10                                                       00005240
R11      EQU   11                                                       00005250
R12      EQU   12                                                       00005260
R13      EQU   13                                                       00005270
R14      EQU   14                                                       00005280
R15      EQU   15                                                       00005290
         END                                                            00005300
