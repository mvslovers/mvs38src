DRP2     CSECT
MYD      DSECT
FLD      DS    F
DRP2C    CSECT
         USING DRP2C,14
         USING MYD,2
         USING MYD,3
         USING MYD,5
         USING MYD,7
         USING MYD,8
         USING MYD,12
         USING MYD,15
         L     0,FLD
         DROP  3,5,7,8,12,15
         L     0,FLD
         END
