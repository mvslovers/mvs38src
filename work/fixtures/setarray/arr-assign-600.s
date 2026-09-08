* 600 distinct subscripts of one declared array (cc370#173)
* 400 is clean at MAXLSET 512; 600 fills the table
ASG600    CSECT
         MACRO
         ARR
         LCLB  &SW(4000)
         LCLA  &I
&I       SETA  0
.L       ANOP
&I       SETA  &I+1
&SW(&I)  SETB  1
         AIF   (&I LT 600).L
         DC    AL2(&I)
         MEND
         ARR
         END
