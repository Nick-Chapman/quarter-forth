
.." Loading dump.f" cr

: show1 ( n a -- )
over 0= if 2drop exit then
dup c@ [char] & emit .hex2 [char] , emit space
1+ swap 1- swap recurse
;

: show ( n a -- )
." equb " show1 0 . cr
;

( over - swap )

dup .hex cr

20 swap

show cr
