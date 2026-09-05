         MACRO                                                          00010000
         RDTRKWA                                                        00020000
WORKAREA DSECT ,                                                        00030000
WRKSA    DC    18A(0)                                                   00040000
         DC    (((((*-WORKAREA)/32)+1)*32)-(*-WORKAREA))X'00'           00050000
WRKID01  DC    CL32'CCW-----------------------------'                   00060000
WRKCCWHA CCW   X'1A',WRKHA,CCWCC,5              READ HOME ADDRESS       00070000
         CCW   X'16',WRKR0,CCWSLI,4             READ RECORD ZERO        00080000
         DC    (((((*-WORKAREA)/32)+1)*32)-(*-WORKAREA))X'00'           00090000
*        READ MAXIMUM COUNT FIELDS ON TRACK                             00100000
WRKCCWRC CCW   X'12',WRKCOUNT+00*8,CCWSLI+CCWCC,8                01     00110000
         CCW   X'12',WRKCOUNT+01*8,CCWSLI+CCWCC,8                02     00120000
         CCW   X'12',WRKCOUNT+02*8,CCWSLI+CCWCC,8                03     00130000
         CCW   X'12',WRKCOUNT+03*8,CCWSLI+CCWCC,8                04     00140000
         CCW   X'12',WRKCOUNT+04*8,CCWSLI+CCWCC,8                05     00150000
         CCW   X'12',WRKCOUNT+05*8,CCWSLI+CCWCC,8                06     00160000
         CCW   X'12',WRKCOUNT+06*8,CCWSLI+CCWCC,8                07     00170000
         CCW   X'12',WRKCOUNT+07*8,CCWSLI+CCWCC,8                08     00180000
         CCW   X'12',WRKCOUNT+08*8,CCWSLI+CCWCC,8                09     00190000
         CCW   X'12',WRKCOUNT+09*8,CCWSLI+CCWCC,8                10     00200000
         CCW   X'12',WRKCOUNT+10*8,CCWSLI+CCWCC,8                11     00210000
         CCW   X'12',WRKCOUNT+11*8,CCWSLI+CCWCC,8                12     00220000
         CCW   X'12',WRKCOUNT+12*8,CCWSLI+CCWCC,8                13     00230000
         CCW   X'12',WRKCOUNT+13*8,CCWSLI+CCWCC,8                14     00240000
         CCW   X'12',WRKCOUNT+14*8,CCWSLI+CCWCC,8                15     00250000
         CCW   X'12',WRKCOUNT+15*8,CCWSLI+CCWCC,8                16     00260000
         CCW   X'12',WRKCOUNT+16*8,CCWSLI+CCWCC,8                17     00270000
         CCW   X'12',WRKCOUNT+17*8,CCWSLI+CCWCC,8                18     00280000
         CCW   X'12',WRKCOUNT+18*8,CCWSLI+CCWCC,8                19     00290000
         CCW   X'12',WRKCOUNT+19*8,CCWSLI+CCWCC,8                20     00300000
         CCW   X'12',WRKCOUNT+20*8,CCWSLI+CCWCC,8                21     00310000
         CCW   X'12',WRKCOUNT+21*8,CCWSLI+CCWCC,8                22     00320000
         CCW   X'12',WRKCOUNT+22*8,CCWSLI+CCWCC,8                23     00330000
         CCW   X'12',WRKCOUNT+23*8,CCWSLI+CCWCC,8                24     00340000
         CCW   X'12',WRKCOUNT+24*8,CCWSLI+CCWCC,8                25     00350000
         CCW   X'12',WRKCOUNT+25*8,CCWSLI+CCWCC,8                26     00360000
         CCW   X'12',WRKCOUNT+26*8,CCWSLI+CCWCC,8                27     00370000
         CCW   X'12',WRKCOUNT+27*8,CCWSLI+CCWCC,8                28     00380000
         CCW   X'12',WRKCOUNT+28*8,CCWSLI+CCWCC,8                29     00390000
         CCW   X'12',WRKCOUNT+29*8,CCWSLI+CCWCC,8                30     00400000
         CCW   X'12',WRKCOUNT+30*8,CCWSLI+CCWCC,8                31     00410000
         CCW   X'12',WRKCOUNT+31*8,CCWSLI+CCWCC,8                32     00420000
         CCW   X'12',WRKCOUNT+32*8,CCWSLI+CCWCC,8                33     00430000
         CCW   X'12',WRKCOUNT+33*8,CCWSLI+CCWCC,8                34     00440000
         CCW   X'12',WRKCOUNT+34*8,CCWSLI+CCWCC,8                35     00450000
         CCW   X'12',WRKCOUNT+35*8,CCWSLI+CCWCC,8                36     00460000
         CCW   X'12',WRKCOUNT+36*8,CCWSLI+CCWCC,8                37     00470000
         CCW   X'12',WRKCOUNT+37*8,CCWSLI+CCWCC,8                38     00480000
         CCW   X'12',WRKCOUNT+38*8,CCWSLI+CCWCC,8                39     00490000
         CCW   X'12',WRKCOUNT+39*8,CCWSLI+CCWCC,8                40     00500000
         CCW   X'12',WRKCOUNT+40*8,CCWSLI+CCWCC,8                41     00510000
         CCW   X'12',WRKCOUNT+41*8,CCWSLI+CCWCC,8                42     00520000
         CCW   X'12',WRKCOUNT+42*8,CCWSLI+CCWCC,8                43     00530000
         CCW   X'12',WRKCOUNT+43*8,CCWSLI+CCWCC,8                44     00540000
         CCW   X'12',WRKCOUNT+44*8,CCWSLI+CCWCC,8                45     00550000
         CCW   X'12',WRKCOUNT+45*8,CCWSLI+CCWCC,8                46     00560000
         CCW   X'12',WRKCOUNT+46*8,CCWSLI+CCWCC,8                47     00570000
         CCW   X'12',WRKCOUNT+47*8,CCWSLI+CCWCC,8                48     00580000
         CCW   X'12',WRKCOUNT+48*8,CCWSLI+CCWCC,8                49     00590000
         CCW   X'12',WRKCOUNT+49*8,CCWSLI+CCWCC,8                50     00600000
         CCW   X'12',WRKCOUNT+50*8,CCWSLI+CCWCC,8                51     00610000
         CCW   X'12',WRKCOUNT+51*8,CCWSLI+CCWCC,8                52     00620000
         CCW   X'12',WRKCOUNT+52*8,CCWSLI+CCWCC,8                53     00630000
         CCW   X'12',WRKCOUNT+53*8,CCWSLI+CCWCC,8                54     00640000
         CCW   X'12',WRKCOUNT+54*8,CCWSLI+CCWCC,8                55     00650000
         CCW   X'12',WRKCOUNT+55*8,CCWSLI+CCWCC,8                56     00660000
         CCW   X'12',WRKCOUNT+56*8,CCWSLI+CCWCC,8                57     00670000
         CCW   X'12',WRKCOUNT+57*8,CCWSLI+CCWCC,8                58     00680000
         CCW   X'12',WRKCOUNT+58*8,CCWSLI+CCWCC,8                59     00690000
         CCW   X'12',WRKCOUNT+59*8,CCWSLI+CCWCC,8                60     00700000
         CCW   X'12',WRKCOUNT+60*8,CCWSLI+CCWCC,8                61     00710000
         CCW   X'12',WRKCOUNT+61*8,CCWSLI+CCWCC,8                62     00720000
         CCW   X'12',WRKCOUNT+62*8,CCWSLI+CCWCC,8                63     00730000
         CCW   X'12',WRKCOUNT+63*8,CCWSLI+CCWCC,8                64     00740000
         CCW   X'12',WRKCOUNT+64*8,CCWSLI+CCWCC,8                65     00750000
         CCW   X'12',WRKCOUNT+65*8,CCWSLI+CCWCC,8                66     00760000
         CCW   X'12',WRKCOUNT+66*8,CCWSLI+CCWCC,8                67     00770000
         CCW   X'12',WRKCOUNT+67*8,CCWSLI+CCWCC,8                68     00780000
         CCW   X'12',WRKCOUNT+68*8,CCWSLI+CCWCC,8                69     00790000
         CCW   X'12',WRKCOUNT+69*8,CCWSLI+CCWCC,8                70     00800000
         CCW   X'12',WRKCOUNT+70*8,CCWSLI+CCWCC,8                71     00810000
         CCW   X'12',WRKCOUNT+71*8,CCWSLI+CCWCC,8                72     00820000
         CCW   X'12',WRKCOUNT+72*8,CCWSLI+CCWCC,8                73     00830000
         CCW   X'12',WRKCOUNT+73*8,CCWSLI+CCWCC,8                74     00840000
         CCW   X'12',WRKCOUNT+74*8,CCWSLI+CCWCC,8                75     00850000
         CCW   X'12',WRKCOUNT+75*8,CCWSLI+CCWCC,8                76     00860000
         CCW   X'12',WRKCOUNT+76*8,CCWSLI+CCWCC,8                77     00870000
         CCW   X'12',WRKCOUNT+77*8,CCWSLI+CCWCC,8                78     00880000
         CCW   X'12',WRKCOUNT+78*8,CCWSLI+CCWCC,8                79     00890000
         CCW   X'12',WRKCOUNT+79*8,CCWSLI+CCWCC,8                80     00900000
         CCW   X'12',WRKCOUNT+80*8,CCWSLI+CCWCC,8                81     00910000
         CCW   X'12',WRKCOUNT+81*8,CCWSLI+CCWCC,8                82     00920000
         CCW   X'12',WRKCOUNT+82*8,CCWSLI+CCWCC,8                83     00930000
         CCW   X'12',WRKCOUNT+83*8,CCWSLI+CCWCC,8                84     00940000
         CCW   X'12',WRKCOUNT+84*8,CCWSLI+CCWCC,8                85     00950000
         CCW   X'12',WRKCOUNT+85*8,CCWSLI+CCWCC,8                86     00960000
         CCW   X'12',WRKCOUNT+86*8,CCWSLI+CCWCC,8                87     00970000
         CCW   X'12',WRKCOUNT+87*8,CCWSLI+CCWCC,8                88     00980000
         CCW   X'12',WRKCOUNT+88*8,CCWSLI+CCWCC,8                89     00990000
         CCW   X'12',WRKCOUNT+89*8,CCWSLI,8                      90     01000000
         DC    (((((*-WORKAREA)/32)+1)*32)-(*-WORKAREA))X'00'           01010000
*        READ KEY AND DATA CCWS                                         01020000
WRKCCWKD CCW   X'0E',0,0,0                                       01     01030000
         CCW   X'0E',0,0,0                                       02     01040000
         CCW   X'0E',0,0,0                                       03     01050000
         CCW   X'0E',0,0,0                                       04     01060000
         CCW   X'0E',0,0,0                                       05     01070000
         CCW   X'0E',0,0,0                                       06     01080000
         CCW   X'0E',0,0,0                                       07     01090000
         CCW   X'0E',0,0,0                                       08     01100000
         CCW   X'0E',0,0,0                                       09     01110000
         CCW   X'0E',0,0,0                                       10     01120000
         CCW   X'0E',0,0,0                                       11     01130000
         CCW   X'0E',0,0,0                                       12     01140000
         CCW   X'0E',0,0,0                                       13     01150000
         CCW   X'0E',0,0,0                                       14     01160000
         CCW   X'0E',0,0,0                                       15     01170000
         CCW   X'0E',0,0,0                                       16     01180000
         CCW   X'0E',0,0,0                                       17     01190000
         CCW   X'0E',0,0,0                                       18     01200000
         CCW   X'0E',0,0,0                                       19     01210000
         CCW   X'0E',0,0,0                                       20     01220000
         CCW   X'0E',0,0,0                                       21     01230000
         CCW   X'0E',0,0,0                                       22     01240000
         CCW   X'0E',0,0,0                                       23     01250000
         CCW   X'0E',0,0,0                                       24     01260000
         CCW   X'0E',0,0,0                                       25     01270000
         CCW   X'0E',0,0,0                                       26     01280000
         CCW   X'0E',0,0,0                                       27     01290000
         CCW   X'0E',0,0,0                                       28     01300000
         CCW   X'0E',0,0,0                                       29     01310000
         CCW   X'0E',0,0,0                                       30     01320000
         CCW   X'0E',0,0,0                                       31     01330000
         CCW   X'0E',0,0,0                                       32     01340000
         CCW   X'0E',0,0,0                                       33     01350000
         CCW   X'0E',0,0,0                                       34     01360000
         CCW   X'0E',0,0,0                                       35     01370000
         CCW   X'0E',0,0,0                                       36     01380000
         CCW   X'0E',0,0,0                                       37     01390000
         CCW   X'0E',0,0,0                                       38     01400000
         CCW   X'0E',0,0,0                                       39     01410000
         CCW   X'0E',0,0,0                                       40     01420000
         CCW   X'0E',0,0,0                                       41     01430000
         CCW   X'0E',0,0,0                                       42     01440000
         CCW   X'0E',0,0,0                                       43     01450000
         CCW   X'0E',0,0,0                                       44     01460000
         CCW   X'0E',0,0,0                                       45     01470000
         CCW   X'0E',0,0,0                                       46     01480000
         CCW   X'0E',0,0,0                                       47     01490000
         CCW   X'0E',0,0,0                                       48     01500000
         CCW   X'0E',0,0,0                                       49     01510000
         CCW   X'0E',0,0,0                                       50     01520000
         CCW   X'0E',0,0,0                                       51     01530000
         CCW   X'0E',0,0,0                                       52     01540000
         CCW   X'0E',0,0,0                                       53     01550000
         CCW   X'0E',0,0,0                                       54     01560000
         CCW   X'0E',0,0,0                                       55     01570000
         CCW   X'0E',0,0,0                                       56     01580000
         CCW   X'0E',0,0,0                                       57     01590000
         CCW   X'0E',0,0,0                                       58     01600000
         CCW   X'0E',0,0,0                                       59     01610000
         CCW   X'0E',0,0,0                                       60     01620000
         CCW   X'0E',0,0,0                                       61     01630000
         CCW   X'0E',0,0,0                                       62     01640000
         CCW   X'0E',0,0,0                                       63     01650000
         CCW   X'0E',0,0,0                                       64     01660000
         CCW   X'0E',0,0,0                                       65     01670000
         CCW   X'0E',0,0,0                                       66     01680000
         CCW   X'0E',0,0,0                                       67     01690000
         CCW   X'0E',0,0,0                                       68     01700000
         CCW   X'0E',0,0,0                                       69     01710000
         CCW   X'0E',0,0,0                                       70     01720000
         CCW   X'0E',0,0,0                                       71     01730000
         CCW   X'0E',0,0,0                                       72     01740000
         CCW   X'0E',0,0,0                                       73     01750000
         CCW   X'0E',0,0,0                                       74     01760000
         CCW   X'0E',0,0,0                                       75     01770000
         CCW   X'0E',0,0,0                                       76     01780000
         CCW   X'0E',0,0,0                                       77     01790000
         CCW   X'0E',0,0,0                                       78     01800000
         CCW   X'0E',0,0,0                                       79     01810000
         CCW   X'0E',0,0,0                                       80     01820000
         CCW   X'0E',0,0,0                                       81     01830000
         CCW   X'0E',0,0,0                                       82     01840000
         CCW   X'0E',0,0,0                                       83     01850000
         CCW   X'0E',0,0,0                                       84     01860000
         CCW   X'0E',0,0,0                                       85     01870000
         CCW   X'0E',0,0,0                                       86     01880000
         CCW   X'0E',0,0,0                                       87     01890000
         CCW   X'0E',0,0,0                                       88     01900000
         CCW   X'0E',0,0,0                                       89     01910000
         CCW   X'0E',0,0,0                                       90     01920000
*        EXTRA CCWS (2 PER EOF RECORD ON TRACK)                         01930015
         CCW   X'12',0,0,0                                       01     01940010
         CCW   X'12',0,0,0                                       02     01950010
         CCW   X'12',0,0,0                                       03     01960010
         CCW   X'12',0,0,0                                       04     01970010
         CCW   X'12',0,0,0                                       05     01980010
         CCW   X'12',0,0,0                                       06     01990010
         CCW   X'12',0,0,0                                       07     02000010
         CCW   X'12',0,0,0                                       08     02010010
         CCW   X'12',0,0,0                                       09     02020010
         CCW   X'12',0,0,0                                       10     02030010
         CCW   X'12',0,0,0                                       11     02040010
         CCW   X'12',0,0,0                                       12     02050010
         CCW   X'12',0,0,0                                       13     02060010
         CCW   X'12',0,0,0                                       14     02070010
         CCW   X'12',0,0,0                                       15     02080010
         CCW   X'12',0,0,0                                       16     02090010
         CCW   X'12',0,0,0                                       17     02100010
         CCW   X'12',0,0,0                                       18     02110010
         CCW   X'12',0,0,0                                       19     02120010
         CCW   X'12',0,0,0                                       20     02130010
         CCW   X'12',0,0,0                                       21     02140010
         CCW   X'12',0,0,0                                       22     02150010
         CCW   X'12',0,0,0                                       23     02160010
         CCW   X'12',0,0,0                                       24     02170010
         CCW   X'12',0,0,0                                       25     02180010
         CCW   X'12',0,0,0                                       26     02190010
         CCW   X'12',0,0,0                                       27     02200010
         CCW   X'12',0,0,0                                       28     02210010
         CCW   X'12',0,0,0                                       29     02220010
         CCW   X'12',0,0,0                                       30     02230010
         CCW   X'12',0,0,0                                       31     02240010
         CCW   X'12',0,0,0                                       32     02250010
         CCW   X'12',0,0,0                                       33     02260015
         CCW   X'12',0,0,0                                       34     02270015
         CCW   X'12',0,0,0                                       35     02280015
         CCW   X'12',0,0,0                                       36     02290015
         CCW   X'12',0,0,0                                       37     02300015
         CCW   X'12',0,0,0                                       38     02310015
         CCW   X'12',0,0,0                                       39     02320015
         CCW   X'12',0,0,0                                       40     02330015
         CCW   X'12',0,0,0                                       41     02340015
         CCW   X'12',0,0,0                                       42     02350015
         CCW   X'12',0,0,0                                       43     02360015
         CCW   X'12',0,0,0                                       44     02370015
         CCW   X'12',0,0,0                                       45     02380015
         CCW   X'12',0,0,0                                       46     02390015
         CCW   X'12',0,0,0                                       47     02400015
         CCW   X'12',0,0,0                                       48     02410015
         CCW   X'12',0,0,0                                       49     02420015
         CCW   X'12',0,0,0                                       50     02430015
         CCW   X'12',0,0,0                                       51     02440015
         CCW   X'12',0,0,0                                       52     02450015
         CCW   X'12',0,0,0                                       53     02460015
         CCW   X'12',0,0,0                                       54     02470015
         CCW   X'12',0,0,0                                       55     02480015
         CCW   X'12',0,0,0                                       56     02490015
         CCW   X'12',0,0,0                                       57     02500015
         CCW   X'12',0,0,0                                       58     02510015
         CCW   X'12',0,0,0                                       59     02520015
         CCW   X'12',0,0,0                                       60     02530015
         CCW   X'12',0,0,0                                       61     02540015
         CCW   X'12',0,0,0                                       62     02550015
         CCW   X'12',0,0,0                                       63     02560015
         CCW   X'12',0,0,0                                       64     02570015
WRKCCWRE EQU   *                                                        02580010
*                                                                       02590010
         DC    (((((*-WORKAREA)/32)+1)*32)-(*-WORKAREA))X'00'           02600000
WRKID02  DC    CL32'STATUS--------------------------'                   02610005
WRKHAIOB DC    XL40'0'                                                  02620005
WRKHAECB DC    XL4'0'                                                   02630000
WRKHASNS EQU   WRKHAIOB+2                                               02640005
WRKHACSW EQU   WRKHAIOB+8                                               02650005
WRKHACCW EQU   WRKHAIOB+16                                              02660005
WRKHASEK EQU   WRKHAIOB+32                                              02670005
         DC    (((((*-WORKAREA)/32)+1)*32)-(*-WORKAREA))X'00'           02680000
WRKCTIOB DC    XL40'0'                                                  02690005
WRKCTECB DC    XL4'0'                                                   02700005
         DC    (((((*-WORKAREA)/32)+1)*32)-(*-WORKAREA))X'00'           02710000
WRKDTIOB DC    XL40'0'                                                  02720005
WRKDTECB DC    XL4'0'                                                   02730005
         DC    (((((*-WORKAREA)/32)+1)*32)-(*-WORKAREA))X'00'           02740000
WRKID03  DC    CL32'ECB-----------------------------'                   02750000
WRKECB   DC    A(0)                                                     02760000
*                                                                       02770000
         DC    (((((*-WORKAREA)/32)+1)*32)-(*-WORKAREA))X'00'           02780000
WRKID04  DC    CL32'IOB-----------------------------'                   02790000
WRKIOB   DS    0XL40                                                    02800000
WRKIOBF1 DC    B'01000010'  COMMAND CHAIN AND NON-RELATED BITS          02810000
WRKIOBF2 DC    X'0'                                                     02820000
WRKIOBS0 DC    X'0'                                                     02830000
WRKIOBS1 DC    X'0'                                                     02840000
WRKIOBCC DC    X'0'                                                     02850000
WRKIOBEC DC    AL3(WRKECB)                                              02860000
WRKIOBF3 DC    X'0'                                                     02870000
WRKIOBCS DC    XL7'0'                                                   02880000
WRKIOBSC DC    X'0'                                                     02890000
WRKIOBAD DC    AL3(WRKCCWHA)                                            02900000
         DC    X'0'                                                     02910000
WRKIOBDC DC    AL3(WRKDCB)                                              02920000
WRKIOBRE DC    X'0'                                                     02930000
         DC    AL3(0)                                                   02940000
WRKIOBCA DC    XL2'0'                                                   02950000
WRKIOBCT DC    XL2'0'                                                   02960000
WRKIOBSK DC    XL8'0'                                                   02970000
*                                                                       02980000
         DC    (((((*-WORKAREA)/32)+1)*32)-(*-WORKAREA))X'00'           02990000
WRKID05  DC    CL32'HA------------------------------'                   03000000
WRKHA    DS    0XL5       HOME ADDRESS                                  03010000
WRKHAFL  DC    X'0'                                                     03020000
WRKHACC  DC    XL2'0'                                                   03030000
WRKHAHH  DC    XL2'0'                                                   03040000
*                                                                       03050000
         DC    (((((*-WORKAREA)/32)+1)*32)-(*-WORKAREA))X'00'           03060000
WRKID06  DC    CL32'R0------------------------------'                   03070000
WRKR0    DS    0XL4       RECORD ZERO                                   03080000
WRKR0CC  DC    XL2'0'                                                   03090000
WRKR0HH  DC    XL2'0'                                                   03100000
*                                                                       03110000
         DC    (((((*-WORKAREA)/32)+1)*32)-(*-WORKAREA))X'00'           03120000
WRKID07  DC    CL32'FMT4----------------------------'                   03130000
WRKFMT4  DC    XL96'0'                                                  03140000
*                                                                       03150000
         DC    (((((*-WORKAREA)/32)+1)*32)-(*-WORKAREA))X'00'           03160000
WRKID08  DC    CL32'JFCB----------------------------'                   03170000
WRKJFCB  DC    XL176'0'                                                 03180000
*                                                                       03190000
         DC    (((((*-WORKAREA)/32)+1)*32)-(*-WORKAREA))X'00'           03200000
WRKID09  DC    CL32'DCB-----------------------------'                   03210000
WRKDCB   DCB   DSORG=PS,DDNAME=DASD,MACRF=(E),                         *03220001
               IOBAD=WRKIOB,EXLST=WRKDCBXT                              03230001
*                                                                       03240000
WRKDCBXT DC    0F'0',X'87',AL3(WRKJFCB)                                 03250000
*                                                                       03260000
WRKOPNLS OPEN  (0,(INPUT)),MF=L                                         03270000
*                                                                       03280000
WRKSRCLS CAMLST SEARCH,WRKJFCB,WRKJFCB+118,WRKFMT4 READ FORMAT 4 DSCB   03290000
*********************************************************************** 03300000
         DC    (((((*-WORKAREA)/32)+1)*32)-(*-WORKAREA))X'00'           03310000
WRKID10  DC    CL32'WORK----------------------------'                   03320000
WRKIOCNT DC    F'0'                                                     03330003
WRKCCHH  DC    F'0'       * KEEP                                        03340006
WRKRECNO DC    X'0'       *  TOGETHER                                   03350006
WRKMAXCY DC    H'0'                                                     03360000
WRKMAXTR DC    H'0'                                                     03370000
WRKALLTR DC    H'0'                                                     03380000
WRKSVDEB DC    XL16'0'                                                  03390000
WRKDEVAR DC    8A(0)                                                    03400000
*********************************************************************** 03410000
         DC    (((((*-WORKAREA)/32)+1)*32)-(*-WORKAREA))X'00'           03420000
WRKID11  DC    CL32'COUNT---------------------------'                   03430000
WRKCOUNT DC    91XL8'00'                                                03440000
WRKCNTLN EQU   *-WRKCOUNT                                               03450002
         DC    (((((*-WORKAREA)/32)+1)*32)-(*-WORKAREA))X'00'           03460000
WRKID12  DC    CL32'BUFFER--------------------------'                   03470000
WRKBUF   DC    64XL256'00'                                              03480000
         DC    64XL256'00'                                              03490000
         DC    64XL256'00'                                              03500000
         DC    64XL256'00'                                              03510000
WRKBUFLN EQU   *-WRKBUF                                                 03520002
*********************************************************************** 03530000
         DC    (((((*-WORKAREA)/4096)+1)*4096)-(*-WORKAREA))X'00'       03540000
WRKID13  DC    CL32'RDTRKWAEND----------------------'                   03550013
WORKLEN  EQU   *-WORKAREA                                               03560000
         MEND                                                           03570000
