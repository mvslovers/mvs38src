Q        CSECT
         USING *,15
F        DS    C
QUOTE    EQU   C''''
AEQ      EQU   C'A'
         CLI   F,QUOTE
         CLI   F,AEQ
         DC    AL1(QUOTE)
         END
