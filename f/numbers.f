.." Loading numbers ( " latest


1 1 +
constant two

two 1 + dup * 1 +
constant ten

( Parse an unsigned decimal )

: digit? ( c -- flag ) dup [char] 0 >= swap [char] 9 <= and ;

: number-loop ( acc str -- u 1 | 0 )
dup c@ dup 0 = if 2drop ( acc ) 1 exit
then ( acc str c ) dup digit? ( acc str c flag )
dup 0 = if 2drop 2drop 0 exit
then drop [char] 0 - rot ten * + swap char+ ( acc' str' )
tail number-loop
;

: number? ( str -- u 1 | 0 )
dup 0 swap number-loop ( s u 1 | s 0 )
dup if rot drop
then
;

( Print as unsigned decimal )

: print-digit ( 0-9 -- )
[char] 0 + emit
;

: dot-loop ( u -- )
dup 0= if drop exit ( stop; don't print leading zeros ) then
ten /mod ( u%10 u/10 -- ) dot-loop print-digit
;

: . ( u -- )
dup 0= if print-digit exit then ( special case for single "0" )
dot-loop
;

: ? ( addr -- ) @ . ;

hide digit?
hide dot-loop
hide number-loop
hide print-digit
hide ten
hide two
words-since char ) emit cr
