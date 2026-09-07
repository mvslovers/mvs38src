*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=* 00000010
*=                                                                   =* 00000020
*=                                                                   =* 00000030
*=                                                                   =* 00000040
*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=* 00000050
HASPFMT5 CSECT                                                          00000060
         DC    CL1'C'                                                   00000070
         DC    XL1'01'                                                  00000080
         DC    CL8'DCT     '                                            00000090
         DC    H'0020'                                                  00000100
         DC    H'0396'                                                  00000110
         DC    CL1'C'                                                   00000120
         DC    XL1'02'                                                  00000130
         DC    CL8'DCT     '                                            00000140
         DC    XL3'001401'                                              00000150
         DC    CL1'0'                                                   00000160
         DC    XL3'000880'                                              00000170
         DC    CL1' '                                                   00000180
         DC    F'02048'                                                 00000190
         DC    CL1'-'                                                   00000200
         DC    XL1'20'                                                  00000210
         DC    CL32'HASP DEVICE CONTROL TABLE (DCT) '                   00000220
         DC    H'4352'                                                  00000230
         DC    CL8'DCTDEVN '                                            00000240
         DC    XL4'00180008'                                            00000250
         DC    CL1' '                                                   00000260
         DC    XL1'1A'                                                  00000270
         DC    CL26'GENERAL DEVICE FOUNDATION '                         00000280
         DC    H'4096'                                                  00000290
         DC    CL8'DCTPCE  '                                            00000300
         DC    H'0'                                                     00000310
         DC    XL4'00040000'                                            00000320
         DC    CL8'DCTSTAT '                                            00000330
         DC    F'00001'                                                 00000340
         DC    H'0'                                                     00000350
         DC    CL8'DCTFLAGS'                                            00000360
         DC    H'0020'                                                  00000370
         DC    F'65536'                                                 00000380
         DC    CL8'DCTBUFAD'                                            00000390
         DC    XL4'00040004'                                            00000400
         DC    H'0'                                                     00000410
         DC    CL8'DCTACB  '                                            00000420
         DC    H'0008'                                                  00000430
         DC    XL4'00040000'                                            00000440
         DC    CL8'DCTEWF  '                                            00000450
         DC    XL4'000C0004'                                            00000460
         DC    H'0'                                                     00000470
         DC    CL8'DCTBUFCT'                                            00000480
         DC    H'0016'                                                  00000490
         DC    F'65536'                                                 00000500
         DC    CL8'DCTDEVTP'                                            00000510
         DC    XL4'00110001'                                            00000520
         DC    H'0'                                                     00000530
         DC    CL8'DCTNO   '                                            00000540
         DC    H'0018'                                                  00000550
         DC    XL4'00020000'                                            00000560
         DC    CL8'DCTCHAIN'                                            00000570
         DC    XL4'00140004'                                            00000580
         DC    XL4'80020011'                                            00000590
         DC    XL4'00B68004'                                            00000600
         DC    XL4'0011003E'                                            00000610
         DC    CL1' '                                                   00000620
         DC    XL1'22'                                                  00000630
         DC    CL32'LOCAL DEVICE FOUNDATION EXTENSIO'                   00000640
         DC    CL2'N '                                                  00000650
         DC    H'4096'                                                  00000660
         DC    CL8'DCTFEORG'                                            00000670
         DC    H'0032'                                                  00000680
         DC    XL4'00148000'                                            00000690
         DC    F'01598'                                                 00000700
         DC    CL1' '                                                   00000710
         DC    XL1'24'                                                  00000720
         DC    CL32'INTERNAL READER FOUNDATION EXTEN'                   00000730
         DC    CL4'SION'                                                00000740
         DC    H'4096'                                                  00000750
         DC    CL8'RIDECBP '                                            00000760
         DC    XL4'00200004'                                            00000770
         DC    H'0'                                                     00000780
         DC    CL8'RIDASCBP'                                            00000790
         DC    H'0036'                                                  00000800
         DC    XL4'00040000'                                            00000810
         DC    CL8'RIDERRET'                                            00000820
         DC    XL4'00280004'                                            00000830
         DC    H'0'                                                     00000840
         DC    CL8'RIDSSVT '                                            00000850
         DC    H'0044'                                                  00000860
         DC    XL4'00040000'                                            00000870
         DC    CL8'RIDECB  '                                            00000880
         DC    XL4'00300004'                                            00000890
         DC    XL4'80000000'                                            00000900
         DC    XL4'05CC8080'                                            00000910
         DC    XL4'002D0238'                                            00000920
         DC    XL4'80200011'                                            00000930
         DC    XL4'01CE8010'                                            00000940
         DC    XL3'001101'                                              00000950
         DC    CL1'H'                                                   00000960
         DC    XL4'80420011'                                            00000970
         DC    XL1'01'                                                  00000980
         DC    CL2'B '                                                  00000990
         DC    XL1'22'                                                  00001000
         DC    CL32'BSC LINE DCT FOUNDATION EXTENSIO'                   00001010
         DC    CL2'N '                                                  00001020
         DC    H'4096'                                                  00001030
         DC    CL8'MDCTADCT'                                            00001040
         DC    XL4'00200004'                                            00001050
         DC    H'0'                                                     00001060
         DC    CL8'MDCTRSEQ'                                            00001070
         DC    H'0036'                                                  00001080
         DC    F'65536'                                                 00001090
         DC    CL8'MDCTTSEQ'                                            00001100
         DC    XL4'00250001'                                            00001110
         DC    H'0'                                                     00001120
         DC    CL8'MDCTMODE'                                            00001130
         DC    H'0038'                                                  00001140
         DC    F'65536'                                                 00001150
         DC    CL8'MDCTERCT'                                            00001160
         DC    XL4'00270001'                                            00001170
         DC    H'0'                                                     00001180
         DC    CL8'MDCTDCT '                                            00001190
         DC    H'0040'                                                  00001200
         DC    XL4'00040000'                                            00001210
         DC    CL8'MDCTLINE'                                            00001220
         DC    XL4'002C0001'                                            00001230
         DC    H'0'                                                     00001240
         DC    CL8'MDCTTYPE'                                            00001250
         DC    H'0045'                                                  00001260
         DC    F'65536'                                                 00001270
         DC    CL8'MDCTATTN'                                            00001280
         DC    XL4'002E0001'                                            00001290
         DC    H'0'                                                     00001300
         DC    CL8'MDCTSTAT'                                            00001310
         DC    H'0047'                                                  00001320
         DC    F'65536'                                                 00001330
         DC    CL8'MDCTBFSZ'                                            00001340
         DC    XL4'00300002'                                            00001350
         DC    H'0'                                                     00001360
         DC    CL8'MDCTFCS '                                            00001370
         DC    H'0050'                                                  00001380
         DC    H'0002'                                                  00001390
         DC    CL1' '                                                   00001400
         DC    XL1'16'                                                  00001410
         DC    CL22'BSC LINE DCT EXTENSION'                             00001420
         DC    H'4352'                                                  00001430
         DC    CL8'MDCTPSWD'                                            00001440
         DC    XL4'00340008'                                            00001450
         DC    H'0'                                                     00001460
         DC    CL8'MDCTOBUF'                                            00001470
         DC    H'0060'                                                  00001480
         DC    XL4'00040000'                                            00001490
         DC    CL8'MDCTIMOK'                                            00001500
         DC    XL1'00'                                                  00001510
         DC    CL1' '                                                   00001520
         DC    H'0004'                                                  00001530
         DC    H'0'                                                     00001540
         DC    CL8'MDCTRAT '                                            00001550
         DC    H'0068'                                                  00001560
         DC    XL4'00040000'                                            00001570
         DC    CL8'MDCTCODE'                                            00001580
         DC    XL4'00480004'                                            00001590
         DC    H'0'                                                     00001600
         DC    CL8'MDCTXCP '                                            00001610
         DC    XL1'00'                                                  00001620
         DC    CL1'<'                                                   00001630
         DC    XL4'00040000'                                            00001640
         DC    CL8'MDCTNAK '                                            00001650
         DC    XL1'00'                                                  00001660
         DC    CL1'&&'                                                  00001670
         DC    H'0004'                                                  00001680
         DC    H'0'                                                     00001690
         DC    CL8'MDCTDCK '                                            00001700
         DC    H'0084'                                                  00001710
         DC    XL4'00040000'                                            00001720
         DC    CL8'MDCTTO  '                                            00001730
         DC    XL4'00580004'                                            00001740
         DC    H'0'                                                     00001750
         DC    CL8'MDCTREM '                                            00001760
         DC    XL1'00'                                                  00001770
         DC    CL1'*'                                                   00001780
         DC    XL4'00040000'                                            00001790
         DC    CL8'MDCTSXCP'                                            00001800
         DC    XL1'00'                                                  00001810
         DC    CL1'-'                                                   00001820
         DC    H'0004'                                                  00001830
         DC    H'0'                                                     00001840
         DC    CL8'MDCTSNAK'                                            00001850
         DC    H'0100'                                                  00001860
         DC    XL4'00040000'                                            00001870
         DC    CL8'MDCTSDCK'                                            00001880
         DC    XL4'00680004'                                            00001890
         DC    H'0'                                                     00001900
         DC    CL8'MDCTSTO '                                            00001910
         DC    XL1'00'                                                  00001920
         DC    CL1'%'                                                   00001930
         DC    XL4'00040000'                                            00001940
         DC    CL8'MDCTSREM'                                            00001950
         DC    XL4'00700004'                                            00001960
         DC    XL4'80000000'                                            00001970
         DC    XL1'06'                                                  00001980
         DC    CL2'B '                                                  00001990
         DC    XL1'24'                                                  00002000
         DC    CL32'BSC REMOTE DCT FOUNDATION EXTENS'                   00002010
         DC    CL4'ION '                                                00002020
         DC    H'4096'                                                  00002030
         DC    CL8'MDCTRECL'                                            00002040
         DC    H'0032'                                                  00002050
         DC    F'65536'                                                 00002060
         DC    CL8'MDCTRCB '                                            00002070
         DC    XL4'00210001'                                            00002080
         DC    H'0'                                                     00002090
         DC    CL8'MDCTFMT '                                            00002100
         DC    H'0034'                                                  00002110
         DC    F'65536'                                                 00002120
         DC    CL8'MDCTFEAT'                                            00002130
         DC    XL4'00230001'                                            00002140
         DC    XL4'80000000'                                            00002150
         DC    XL1'03'                                                  00002160
         DC    CL1'm'                                                   00002170
         DC    XL2'8020'                                                00002180
         DC    XL4'001102CE'                                            00002190
         DC    XL4'80100011'                                            00002200
         DC    XL1'02'                                                  00002210
         DC    CL1'H'                                                   00002220
         DC    XL2'8042'                                                00002230
         DC    XL3'001102'                                              00002240
         DC    CL1'B'                                                   00002250
         DC    XL4'80040011'                                            00002260
         DC    H'0338'                                                  00002270
         DC    CL1' '                                                   00002280
         DC    XL1'22'                                                  00002290
         DC    CL32'SNA LINE DCT FOUNDATION EXTENSIO'                   00002300
         DC    CL2'N '                                                  00002310
         DC    H'4096'                                                  00002320
         DC    CL8'MDCTADCT'                                            00002330
         DC    XL4'00200004'                                            00002340
         DC    H'0'                                                     00002350
         DC    CL8'MDCTICE '                                            00002360
         DC    H'0036'                                                  00002370
         DC    XL4'00040000'                                            00002380
         DC    CL8'MDCTDCT '                                            00002390
         DC    XL4'00280004'                                            00002400
         DC    H'0'                                                     00002410
         DC    CL8'MDCTLINE'                                            00002420
         DC    H'0044'                                                  00002430
         DC    F'65536'                                                 00002440
         DC    CL8'MDCTTYPE'                                            00002450
         DC    XL4'002D0001'                                            00002460
         DC    H'0'                                                     00002470
         DC    CL8'MDCTATTN'                                            00002480
         DC    H'0046'                                                  00002490
         DC    F'65536'                                                 00002500
         DC    CL8'MDCTSTAT'                                            00002510
         DC    XL4'002F0001'                                            00002520
         DC    H'0'                                                     00002530
         DC    CL8'MDCTWICE'                                            00002540
         DC    H'0048'                                                  00002550
         DC    H'0004'                                                  00002560
         DC    CL1' '                                                   00002570
         DC    XL1'16'                                                  00002580
         DC    CL22'SNA LINE DCT EXTENSION'                             00002590
         DC    H'4352'                                                  00002600
         DC    CL8'MDCTPSWD'                                            00002610
         DC    XL4'00340008'                                            00002620
         DC    H'0'                                                     00002630
         DC    CL8'MDCTSNCT'                                            00002640
         DC    H'0060'                                                  00002650
         DC    XL4'00020000'                                            00002660
         DC    CL8'MDCTIMOK'                                            00002670
         DC    XL1'00'                                                  00002680
         DC    CL1' '                                                   00002690
         DC    H'0004'                                                  00002700
         DC    H'0'                                                     00002710
         DC    CL8'MDCTRAT '                                            00002720
         DC    H'0068'                                                  00002730
         DC    XL4'00040000'                                            00002740
         DC    CL8'MDCTCMCT'                                            00002750
         DC    XL4'00480001'                                            00002760
         DC    H'0'                                                     00002770
         DC    CL8'MDCTVREQ'                                            00002780
         DC    XL1'00'                                                  00002790
         DC    CL1'<'                                                   00002800
         DC    XL4'00040000'                                            00002810
         DC    CL8'MDCTXRSP'                                            00002820
         DC    XL1'00'                                                  00002830
         DC    CL1'&&'                                                  00002840
         DC    H'0004'                                                  00002850
         DC    H'0'                                                     00002860
         DC    CL8'MDCTLUST'                                            00002870
         DC    H'0084'                                                  00002880
         DC    XL4'00040000'                                            00002890
         DC    CL8'MDCTBIDR'                                            00002900
         DC    XL4'00580004'                                            00002910
         DC    H'0'                                                     00002920
         DC    CL8'MDCTMPER'                                            00002930
         DC    XL1'00'                                                  00002940
         DC    CL1'*'                                                   00002950
         DC    XL4'00040000'                                            00002960
         DC    CL8'MDCTSCNT'                                            00002970
         DC    XL1'00'                                                  00002980
         DC    CL1'-'                                                   00002990
         DC    H'0020'                                                  00003000
         DC    XL4'80000000'                                            00003010
         DC    H'1274'                                                  00003020
         DC    CL1' '                                                   00003030
         DC    XL1'22'                                                  00003040
         DC    CL32'SNA LOGON DCT FOUNDATION EXTENSI'                   00003050
         DC    CL2'ON'                                                  00003060
         DC    H'4096'                                                  00003070
         DC    CL8'MDCTADCT'                                            00003080
         DC    XL4'00200004'                                            00003090
         DC    H'0'                                                     00003100
         DC    CL8'MDCTICE '                                            00003110
         DC    H'0036'                                                  00003120
         DC    XL4'00040000'                                            00003130
         DC    CL8'MDCTRABF'                                            00003140
         DC    XL4'00280004'                                            00003150
         DC    H'0'                                                     00003160
         DC    CL8'MDCTXERR'                                            00003170
         DC    H'0044'                                                  00003180
         DC    F'65536'                                                 00003190
         DC    CL8'MDCTATYP'                                            00003200
         DC    XL4'002D0001'                                            00003210
         DC    H'0'                                                     00003220
         DC    CL8'MDCTATTN'                                            00003230
         DC    H'0046'                                                  00003240
         DC    F'65536'                                                 00003250
         DC    CL8'MDCTSTAT'                                            00003260
         DC    XL4'002F0001'                                            00003270
         DC    H'0'                                                     00003280
         DC    CL8'MDCTRALM'                                            00003290
         DC    H'0050'                                                  00003300
         DC    F'65536'                                                 00003310
         DC    CL8'MDCTPWDL'                                            00003320
         DC    XL4'00330001'                                            00003330
         DC    CL1' '                                                   00003340
         DC    XL1'18'                                                  00003350
         DC    CL24'SNA LOGON DCT EXTENSION '                           00003360
         DC    H'4352'                                                  00003370
         DC    CL8'MDCTPSWD'                                            00003380
         DC    XL4'00340008'                                            00003390
         DC    H'0'                                                     00003400
         DC    CL8'MDCTSNCT'                                            00003410
         DC    H'0060'                                                  00003420
         DC    XL4'00020000'                                            00003430
         DC    CL8'MDCTRQLM'                                            00003440
         DC    XL4'003E0001'                                            00003450
         DC    H'0'                                                     00003460
         DC    CL8'MDCTAPNL'                                            00003470
         DC    H'0063'                                                  00003480
         DC    F'65792'                                                 00003490
         DC    CL8'MDCTAPPL'                                            00003500
         DC    XL1'00'                                                  00003510
         DC    CL1' '                                                   00003520
         DC    H'0008'                                                  00003530
         DC    H'0'                                                     00003540
         DC    CL8'MDCTRQBF'                                            00003550
         DC    H'0072'                                                  00003560
         DC    XL4'00040000'                                            00003570
         DC    CL8'MDCTLOGN'                                            00003580
         DC    XL1'00'                                                  00003590
         DC    CL1'<'                                                   00003600
         DC    H'0004'                                                  00003610
         DC    H'0'                                                     00003620
         DC    CL8'MDCTNICE'                                            00003630
         DC    XL1'00'                                                  00003640
         DC    CL1'&&'                                                  00003650
         DC    XL4'00040000'                                            00003660
         DC    CL8'MDCTNLNE'                                            00003670
         DC    XL4'00540004'                                            00003680
         DC    H'0'                                                     00003690
         DC    CL8'MDCTINVL'                                            00003700
         DC    H'0088'                                                  00003710
         DC    XL4'00040000'                                            00003720
         DC    CL8'MDCTABRT'                                            00003730
         DC    XL1'00'                                                  00003740
         DC    CL1'*'                                                   00003750
         DC    H'0004'                                                  00003760
         DC    H'0'                                                     00003770
         DC    CL8'MDCTEXIT'                                            00003780
         DC    XL1'00'                                                  00003790
         DC    CL1'-'                                                   00003800
         DC    XL4'00048000'                                            00003810
         DC    F'00912'                                                 00003820
         DC    CL1' '                                                   00003830
         DC    XL1'24'                                                  00003840
         DC    CL32'SNA REMOTE DCT FOUNDATION EXTENS'                   00003850
         DC    CL4'ION '                                                00003860
         DC    H'4096'                                                  00003870
         DC    CL8'MDCTRECL'                                            00003880
         DC    XL4'00200001'                                            00003890
         DC    H'0'                                                     00003900
         DC    CL8'MDCTSEL '                                            00003910
         DC    H'0033'                                                  00003920
         DC    F'65536'                                                 00003930
         DC    CL8'MDCTFMT '                                            00003940
         DC    XL4'00220001'                                            00003950
         DC    H'0'                                                     00003960
         DC    CL8'MDCTFEAT'                                            00003970
         DC    H'0035'                                                  00003980
         DC    F'65536'                                                 00003990
         DC    CL8'MDCTICE '                                            00004000
         DC    XL4'00240004'                                            00004010
         DC    H'0'                                                     00004020
         DC    CL8'MDCTDCT '                                            00004030
         DC    H'0040'                                                  00004040
         DC    XL4'00040000'                                            00004050
         DC    CL8'MDCTLINE'                                            00004060
         DC    XL4'002C0001'                                            00004070
         DC    H'0'                                                     00004080
         DC    CL8'MDCTTYPE'                                            00004090
         DC    H'0045'                                                  00004100
         DC    F'65536'                                                 00004110
         DC    CL8'MDCTSTAT'                                            00004120
         DC    XL4'002F0001'                                            00004130
         DC    H'0'                                                     00004140
         DC    CL8'MDCTBFSZ'                                            00004150
         DC    H'0048'                                                  00004160
         DC    XL4'00020000'                                            00004170
         DC    CL8'MDCTCHLM'                                            00004180
         DC    XL4'00330001'                                            00004190
         DC    XL4'80200011'                                            00004200
         DC    XL1'01'                                                  00004210
         DC    CL1'%'                                                   00004220
         DC    XL2'8042'                                                00004230
         DC    XL4'00110166'                                            00004240
         DC    CL1' '                                                   00004250
         DC    XL1'14'                                                  00004260
         DC    CL20'READER DCT EXTENSION'                               00004270
         DC    H'4096'                                                  00004280
         DC    CL8'DCTDEVID'                                            00004290
         DC    XL4'00340002'                                            00004300
         DC    H'0'                                                     00004310
         DC    CL8'DCTLRECL'                                            00004320
         DC    H'0054'                                                  00004330
         DC    F'65536'                                                 00004340
         DC    CL8'DCTPRRTE'                                            00004350
         DC    XL4'00390001'                                            00004360
         DC    H'0'                                                     00004370
         DC    CL8'DCTPURTE'                                            00004380
         DC    H'0059'                                                  00004390
         DC    F'65536'                                                 00004400
         DC    CL8'DCTSIAFF'                                            00004410
         DC    XL4'003C0001'                                            00004420
         DC    H'0'                                                     00004430
         DC    CL8'DCTRAUTH'                                            00004440
         DC    H'0061'                                                  00004450
         DC    F'65792'                                                 00004460
         DC    CL8'DCTJCLAS'                                            00004470
         DC    XL4'003E0001'                                            00004480
         DC    H'0256'                                                  00004490
         DC    CL8'DCTMCLAS'                                            00004500
         DC    H'0063'                                                  00004510
         DC    F'65536'                                                 00004520
         DC    CL8'DCTPRINC'                                            00004530
         DC    XL1'00'                                                  00004540
         DC    CL1' '                                                   00004550
         DC    H'0001'                                                  00004560
         DC    H'0'                                                     00004570
         DC    CL8'DCTPRLIM'                                            00004580
         DC    H'0065'                                                  00004590
         DC    F'65536'                                                 00004600
         DC    CL8'DCTINDC '                                            00004610
         DC    XL4'00420001'                                            00004620
         DC    XL4'80040011'                                            00004630
         DC    XL4'000C8000'                                            00004640
         DC    F'00520'                                                 00004650
         DC    CL1' '                                                   00004660
         DC    XL1'1E'                                                  00004670
         DC    CL30'INTERNAL READER DCT EXTENSION '                     00004680
         DC    H'4096'                                                  00004690
         DC    CL8'RIDFLAGS'                                            00004700
         DC    H'0067'                                                  00004710
         DC    F'65536'                                                 00004720
         DC    CL8'RIDUBF  '                                            00004730
         DC    XL4'00440004'                                            00004740
         DC    H'0'                                                     00004750
         DC    CL8'RIDPBF  '                                            00004760
         DC    H'0072'                                                  00004770
         DC    XL4'00040000'                                            00004780
         DC    CL8'RIDPBFO '                                            00004790
         DC    XL1'00'                                                  00004800
         DC    CL1'<'                                                   00004810
         DC    H'0004'                                                  00004820
         DC    H'0256'                                                  00004830
         DC    CL8'RIDJOBID'                                            00004840
         DC    XL1'00'                                                  00004850
         DC    CL1'&&'                                                  00004860
         DC    XL4'00080000'                                            00004870
         DC    CL8'RIDEOMP '                                            00004880
         DC    XL4'00580004'                                            00004890
         DC    H'0'                                                     00004900
         DC    CL8'RIDEOMA '                                            00004910
         DC    XL1'00'                                                  00004920
         DC    CL1'*'                                                   00004930
         DC    XL4'00040000'                                            00004940
         DC    CL8'RIDEOMER'                                            00004950
         DC    XL1'00'                                                  00004960
         DC    CL1'-'                                                   00004970
         DC    H'0004'                                                  00004980
         DC    H'0'                                                     00004990
         DC    CL8'RIDEOME '                                            00005000
         DC    H'0100'                                                  00005010
         DC    XL4'00048000'                                            00005020
         DC    F'00356'                                                 00005030
         DC    CL1' '                                                   00005040
         DC    XL1'1A'                                                  00005050
         DC    CL26'PRINT/PUNCH DCT EXTENSION '                         00005060
         DC    H'4096'                                                  00005070
         DC    CL8'DCTDEVID'                                            00005080
         DC    H'0052'                                                  00005090
         DC    XL4'00020000'                                            00005100
         DC    CL8'DCTLRECL'                                            00005110
         DC    XL4'00360001'                                            00005120
         DC    H'0'                                                     00005130
         DC    CL8'DCTLINCT'                                            00005140
         DC    H'0055'                                                  00005150
         DC    F'65792'                                                 00005160
         DC    CL8'DCTFORMS'                                            00005170
         DC    XL4'00380004'                                            00005180
         DC    H'0256'                                                  00005190
         DC    CL8'DCTFCB  '                                            00005200
         DC    H'0060'                                                  00005210
         DC    XL4'00040100'                                            00005220
         DC    CL8'DCTUCS  '                                            00005230
         DC    XL1'00'                                                  00005240
         DC    CL1' '                                                   00005250
         DC    H'0004'                                                  00005260
         DC    H'0'                                                     00005270
         DC    CL8'DCTINDEX'                                            00005280
         DC    H'0068'                                                  00005290
         DC    F'65536'                                                 00005300
         DC    CL8'DCTPPFL '                                            00005310
         DC    XL4'00450001'                                            00005320
         DC    H'0'                                                     00005330
         DC    CL8'DCTPPSW '                                            00005340
         DC    H'0070'                                                  00005350
         DC    F'65536'                                                 00005360
         DC    CL8'DCTPPSW2'                                            00005370
         DC    XL4'00470001'                                            00005380
         DC    H'0256'                                                  00005390
         DC    CL8'DCTCHAR1'                                            00005400
         DC    H'0072'                                                  00005410
         DC    XL4'00040100'                                            00005420
         DC    CL8'DCTCHAR2'                                            00005430
         DC    XL1'00'                                                  00005440
         DC    CL1'<'                                                   00005450
         DC    H'0004'                                                  00005460
         DC    H'0256'                                                  00005470
         DC    CL8'DCTCHAR3'                                            00005480
         DC    XL1'00'                                                  00005490
         DC    CL1'&&'                                                  00005500
         DC    XL4'00040100'                                            00005510
         DC    CL8'DCTCHAR4'                                            00005520
         DC    XL4'00540004'                                            00005530
         DC    H'0256'                                                  00005540
         DC    CL8'DCTFLASH'                                            00005550
         DC    H'0088'                                                  00005560
         DC    XL4'00040100'                                            00005570
         DC    CL8'DCTMODF '                                            00005580
         DC    XL1'00'                                                  00005590
         DC    CL1'*'                                                   00005600
         DC    H'0004'                                                  00005610
         DC    H'0'                                                     00005620
         DC    CL8'DCTLDPID'                                            00005630
         DC    XL1'00'                                                  00005640
         DC    CL1'-'                                                   00005650
         DC    XL4'00020000'                                            00005660
         DC    CL8'DCTDCPTN'                                            00005670
         DC    XL4'00620001'                                            00005680
         DC    H'0'                                                     00005690
         DC    CL8'DCTACPTN'                                            00005700
         DC    H'0099'                                                  00005710
         DC    F'65536'                                                 00005720
         DC    CL8'DCTCKPTP'                                            00005730
         DC    XL4'00640002'                                            00005740
         DC    H'0'                                                     00005750
         DC    CL8'DCTCKPTL'                                            00005760
         DC    H'0102'                                                  00005770
         DC    XL4'00020000'                                            00005780
         DC    CL8'DCTCSW  '                                            00005790
         DC    XL4'00700004'                                            00005800
         DC    H'0256'                                                  00005810
         DC    CL8'DCTCLASS'                                            00005820
         DC    H'0116'                                                  00005830
         DC    XL4'0008C001'                                            00005840
         DC    CL8'PCE     '                                            00005850
         DC    F'0'                                                     00005860
         DC    CL1' '                                                   00005870
         DC    XL1'1E'                                                  00005880
         DC    CL30'PCE ASSOCIATED WITH ABOVE DCT '                     00005890
         DC    H'4096'                                                  00005900
         DC    CL8'PCESAVEA'                                            00005910
         DC    H'0'                                                     00005920
         DC    XL4'00040000'                                            00005930
         DC    CL8'PCEPREV '                                            00005940
         DC    XL4'00040004'                                            00005950
         DC    H'0'                                                     00005960
         DC    CL8'PCENEXT '                                            00005970
         DC    H'0008'                                                  00005980
         DC    XL4'00040000'                                            00005990
         DC    CL8'PCELINK '                                            00006000
         DC    XL4'000C0004'                                            00006010
         DC    H'0'                                                     00006020
         DC    CL8'PCER15  '                                            00006030
         DC    H'0016'                                                  00006040
         DC    XL4'00040000'                                            00006050
         DC    CL8'PCER0   '                                            00006060
         DC    XL4'00140004'                                            00006070
         DC    H'0'                                                     00006080
         DC    CL8'PCER1   '                                            00006090
         DC    H'0024'                                                  00006100
         DC    XL4'00040000'                                            00006110
         DC    CL8'PCEWA   '                                            00006120
         DC    XL4'001C0004'                                            00006130
         DC    H'0'                                                     00006140
         DC    CL8'PCEWB   '                                            00006150
         DC    H'0032'                                                  00006160
         DC    XL4'00040000'                                            00006170
         DC    CL8'PCEWC   '                                            00006180
         DC    XL4'00240004'                                            00006190
         DC    H'0'                                                     00006200
         DC    CL8'PCEWD   '                                            00006210
         DC    H'0040'                                                  00006220
         DC    XL4'00040000'                                            00006230
         DC    CL8'PCEWE   '                                            00006240
         DC    XL4'002C0004'                                            00006250
         DC    H'0'                                                     00006260
         DC    CL8'PCEWF   '                                            00006270
         DC    H'0048'                                                  00006280
         DC    XL4'00040000'                                            00006290
         DC    CL8'PCEBASE3'                                            00006300
         DC    XL4'00340004'                                            00006310
         DC    H'0'                                                     00006320
         DC    CL8'PCER9   '                                            00006330
         DC    H'0056'                                                  00006340
         DC    XL4'00040000'                                            00006350
         DC    CL8'PCEJCT  '                                            00006360
         DC    XL4'003C0004'                                            00006370
         DC    H'0'                                                     00006380
         DC    CL8'PCEBASE1'                                            00006390
         DC    XL1'00'                                                  00006400
         DC    CL1' '                                                   00006410
         DC    XL4'00040000'                                            00006420
         DC    CL8'PCEBASE2'                                            00006430
         DC    XL4'00440004'                                            00006440
         DC    H'0'                                                     00006450
         DC    CL8'PCEPCEA '                                            00006460
         DC    H'0072'                                                  00006470
         DC    XL4'00040000'                                            00006480
         DC    CL8'PCEPCEB '                                            00006490
         DC    XL1'00'                                                  00006500
         DC    CL1'<'                                                   00006510
         DC    H'0004'                                                  00006520
         DC    H'0'                                                     00006530
         DC    CL8'PCEEWF  '                                            00006540
         DC    XL1'00'                                                  00006550
         DC    CL1'&&'                                                  00006560
         DC    XL4'00020000'                                            00006570
         DC    CL8'PCEID   '                                            00006580
         DC    XL4'00520002'                                            00006590
         DC    H'0'                                                     00006600
         DC    CL8'PCEDADCT'                                            00006610
         DC    H'0084'                                                  00006620
         DC    XL4'00080000'                                            00006630
         DC    CL8'PCEBUFAD'                                            00006640
         DC    XL4'00580004'                                            00006650
         DC    H'0'                                                     00006660
         DC    CL8'PCESEEK '                                            00006670
         DC    XL1'00'                                                  00006680
         DC    CL1'*'                                                   00006690
         DC    XL4'00040000'                                            00006700
         DC    CL8'PCEIOEWF'                                            00006710
         DC    XL1'00'                                                  00006720
         DC    CL1'-'                                                   00006730
         DC    H'0004'                                                  00006740
         DC    H'0'                                                     00006750
         DC    CL8'PCEBUFCT'                                            00006760
         DC    H'0100'                                                  00006770
         DC    F'65536'                                                 00006780
         DC    CL8'PCEDEVTP'                                            00006790
         DC    XL4'00650001'                                            00006800
         DC    H'0'                                                     00006810
         DC    CL8'PCEDCT  '                                            00006820
         DC    H'0104'                                                  00006830
         DC    XL4'00040000'                                            00006840
         DC    CL8'PCEJQE  '                                            00006850
         DC    XL1'00'                                                  00006860
         DC    CL1'%'                                                   00006870
         DC    H'0004'                                                  00006880
         DC    H'0'                                                     00006890
         DC    CL8'PCEWORK '                                            00006900
         DC    H'0112'                                                  00006910
         DC    XL1'01'                                                  00006920
         DC    CL1' '                                                   00006930
         DC    XL2'FFFF'                                                00006940
         DC    XL4'FFFF0000'                                            00006950
R0       EQU   0                                                        00006960
R1       EQU   1                                                        00006970
R2       EQU   2                                                        00006980
R3       EQU   3                                                        00006990
R4       EQU   4                                                        00007000
R5       EQU   5                                                        00007010
R6       EQU   6                                                        00007020
R7       EQU   7                                                        00007030
R8       EQU   8                                                        00007040
R9       EQU   9                                                        00007050
R10      EQU   10                                                       00007060
R11      EQU   11                                                       00007070
R12      EQU   12                                                       00007080
R13      EQU   13                                                       00007090
R14      EQU   14                                                       00007100
R15      EQU   15                                                       00007110
         END                                                            00007120
