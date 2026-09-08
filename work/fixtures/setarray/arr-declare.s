* declaring a 4000-element local array must cost nothing (cc370#173)
DECL     CSECT
         MACRO
         ARR
         LCLB  &SW(4000)
         LCLA  &I
&I       SETA  1
&SW(&I)  SETB  1
         DC    AL2(&I)
         MEND
         ARR
         END
