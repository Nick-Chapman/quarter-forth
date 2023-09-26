( Lines in this file must be within 79 cols, because buffered input may be on )

cr
.." Welcome to Quarter Forth. A 16-bit Forth system running on x86." cr
cr
mem cr
.?stack

: wipe ( a -- )
[ here ] literal x-hide ( Hide this function when run. )
sp over - 2 - erase ( Wipe memory upto the top of the parameter stack. )
( We must enable echo here, rather than after the call below )
echo-on
;

startup-is-complete
hide startup-is-complete
hide crash-only-during-startup

here wipe
Everything after the call to "wipe" will be wiped!
