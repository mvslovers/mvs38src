ONESECT  CSECT
         USING ONESECT,15
         L     1,=F'7'
         DS    XL8
DPRC     DSECT
         DS    XL256
         CSECT
         TRT   0(2,1),0(1)
         END
