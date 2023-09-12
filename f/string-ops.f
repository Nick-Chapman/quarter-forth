.." Loading string-ops ( " latest

hide s=
hide type

( Recode in Forth the core string-ops needed in boot & for word/find )

: s= ( a1 a2 -- flag )
over over c@ swap c@ over ( a1 a2 c2 c1 c2 ) = if
0 = if drop drop 0 1 - exit then
1 + swap 1 + tail s=
then drop drop drop 0
;

: type ( a -- )
dup c@ ( a c ) dup if ( a c ) emit ( a ) 1 + tail type
then drop drop
;


words-since char ) emit cr
