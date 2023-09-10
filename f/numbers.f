.." Loading numbers ( " latest

( Make the numbers we need )

1 1 +
constant 2

2 1 + dup * 1 +
constant 10

2 dup * dup *
constant 16

16 dup *
constant 256

( Parse an unsigned decimal )

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

( Print as unsigned decimal )

: print-digit ( 0-9 -- )
[char] 0 + emit
;

: dot-loop ( u -- )
dup 0= if drop exit ( stop; don't print leading zeros ) then
10 /mod ( u%10 u/10 -- ) dot-loop print-digit
;

: .decimal ( n -- ) ( output a value in decimal, with trailing space )
dup 0= if print-digit exit then ( special case for single "0" )
dot-loop
space
;

: .hex1 ( nibble -- ) ( output nibble as a length-1 hex string )
dup 10 < if print-digit exit then 10 - [char] a + emit ;

: .hex2 ( byte -- ) ( output byte as a length-2 hex string )
16 /mod .hex1 .hex1 ;

: .hex4 ( n -- ) ( output 16-bit cell-value as a length-4 hex string )
256 /mod .hex2 .hex2 ;

: .hex ( n -- ) ( output a value in hex, with trailing space )
.hex4 space ;


( Modal . )

variable hex-mode

: hex       true  hex-mode ! ;
: decimal   false hex-mode ! ;

: . ( u -- ) hex-mode @ if .hex exit then .decimal ;

: ? ( addr -- ) @ . ;

hide 10
hide 16
hide 2
hide 256
hide digit?
hide dot-loop
hide number-loop
hide print-digit
hide hex-mode
hide .hex1
words-since char ) emit cr
