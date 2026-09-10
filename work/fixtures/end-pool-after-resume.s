POOLA    CSECT
         USING POOLA,15
         L     1,=F'7'
         DS    XL8
POOLB    CSECT
         DS    XL16
POOLA    CSECT
         TRT   0(2,1),0(1)
         END
