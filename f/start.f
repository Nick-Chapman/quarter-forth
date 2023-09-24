cr
.." Welcome to Quarter Forth. A 16-bit Forth system running on x86." cr
cr
mem cr
.?stack

: wipe ( a -- )
[ here ] literal x-hide ( Hide this function when run. )
sp over - 1000 - erase ( Wipe memory upto the top of the parameter stack. )
( We must enable echo here, rather than after the call below, because that will be wiped! )
echo-on
;

' buffered-key set-key ( Install the buffered-key input routine )
startup-is-complete
hide startup-is-complete
hide crash-only-during-startup
here wipe

Everything from here will be wiped, so anything goes!
