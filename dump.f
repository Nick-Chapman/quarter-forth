
.." Loading dump.f" cr

: .s-continue
2 -
dup 2 - sp > if ( the 2 is for the extra item while processing )
dup @ .
recurse
then
drop
;

: .s
sp0 .s-continue
;

: show ( n a -- )
over 0= if 2drop exit then
( dup as-num .hex ."  = " dup c@ .hex2 cr )
dup c@ .hex2 space
1+ swap 1- swap recurse
;

( here over - swap )
20 swap

show cr
