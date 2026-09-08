* an inner macro's locals must not leak into the outer context
* 20 locals declared, 60 nested invocations (cc370#173)
NOLEAK   CSECT
         MACRO
         INNER &K
         LCLA  &A0
         LCLA  &A1
         LCLA  &A2
         LCLA  &A3
         LCLA  &A4
         LCLA  &A5
         LCLA  &A6
         LCLA  &A7
         LCLA  &A8
         LCLA  &A9
         LCLA  &A10
         LCLA  &A11
         LCLA  &A12
         LCLA  &A13
         LCLA  &A14
         LCLA  &A15
         LCLA  &A16
         LCLA  &A17
         LCLA  &A18
         LCLA  &A19
&A0      SETA  &K
         DC    AL2(&A0)
         MEND
         MACRO
         OUTER
         LCLA  &I
&I       SETA  0
.L       ANOP
&I       SETA  &I+1
         INNER &I
         AIF   (&I LT 60).L
         MEND
         OUTER
         END
