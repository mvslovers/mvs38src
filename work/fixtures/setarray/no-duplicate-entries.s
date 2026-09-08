* repeated assignment to the SAME symbol must not consume table entries
* 5000 SETAs against two symbols -- if this ever fails, the store has
* started adding a row per assignment rather than per name (cc370#173)
NODUP    CSECT
         MACRO
         REP   &N
         LCLA  &I,&X
&I       SETA  0
.LOOP    ANOP
&I       SETA  &I+1
&X       SETA  &I*2
         AIF   (&I LT &N).LOOP
         DC    AL2(&X)
         MEND
         REP   5000
         END
