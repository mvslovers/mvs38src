STYP     CSECT
         USING STYP,12
LAB      DS    F
CRCA     EQU   0
CRCAMCW  EQU   CRCA+8
         USING CRCA,1
         DC    S(CRCAMCW)
         DC    S(LAB)
         DC    S(0)
         DC    S(8)
         DROP  1
         DC    S(0)
         DC    S(LAB)
         END
