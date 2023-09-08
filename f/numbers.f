.." Loading numbers ( " latest

: char+   ( n -- n )        1 + ;       ( increment by char size +1 )
: rot   >r swap r> swap ;
: 2drop drop drop ;
: false     ( -- b )        0 ;
: true      ( -- b )        0 1 - ;
: and       ( b1 b2 -- b )  if exit then drop false ;   ( bool conjunction )
: invert    ( b -- b )      if false exit then true ;   ( bool negation )
: >         swap < ;
: <=        > invert ;
: >=        < invert ;
: 0=   0 = ;

: digit? ( c -- flag ) dup [char] 0 >= swap [char] 9 <= and ;

: number-loop ( acc str -- u 1 | 0 )
dup c@ dup 0 = if 2drop ( acc ) 1 exit
then ( acc str c ) dup digit? ( acc str c flag )
dup 0 = if 2drop 2drop 0 exit
then drop [char] 0 - rot 10 * + swap char+ ( acc' str' )
tail number-loop
;

: number? ( str -- u 1 | 0 )
dup 0 swap number-loop ( s u 1 | s 0 )
dup if rot drop
then
;

( Print as unsigned )

: print-digit ( 0-9 -- )
[char] 0 + emit
;

: dot-loop ( u -- )
dup 0= if drop exit ( stop; don't print leading zeros ) then
10 /mod ( u%10 u/10 -- ) dot-loop print-digit
;

: . ( u -- )
dup 0= if print-digit exit then ( special case for single "0" )
dot-loop
;

hide print-digit
hide dot-loop
hide 0=
hide 2drop
hide <=
hide >
hide >=
hide and
hide char+
hide digit?
hide false
hide invert
hide number-loop
hide rot
hide true
words-since char ) emit cr
