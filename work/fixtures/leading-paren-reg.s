REGFIX   CSECT
         USING REGFIX,15
LINUM2   EQU   8
CTR      EQU   8
TWO      EQU   2
A        EQU   3
         LR    0,(3)
         LR    1,(A)
         LR    2,A
         LR    3,(LINUM2+CTR)/TWO
         LR    4,LINUM2+CTR/TWO
         LR    5,4
         END
