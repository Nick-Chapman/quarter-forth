.." Loading primes" cr

: divisible-by ( n1 n2  -- flag ) mod 0= ;

: any-divide ( n list -- flag )
dup c@ ( n list cand|0 ) dup 0= if drop 2drop false exit
then -rot swap rot over swap ( list n n cand )
divisible-by if 2drop true exit then
swap ( n list ) char+ tail any-divide
;

( Fixed table of small primes below 16 )
here
2 c, 3 c, 5 c, 7 c, 11 c, 13 c, 0 c,
constant primes-below-16

: is-small-prime ( n -- flag ) primes-below-16 any-divide invert ;

: small-loop ( n list -- )
dup 256 = if drop exit then
dup is-small-prime if
dup c, ( write prime here )
then 1 + tail small-loop
;

( Generate table of primes under 256 at compile time )
here
16 small-loop 0 c, ( end marker )
constant primes-below-256

: is-big-prime ( n -- flag )
dup
primes-below-16 any-divide if drop false exit then
primes-below-256 any-divide invert
;

: big-loop ( n list -- )
dup 0 = if drop exit then
dup is-big-prime if dup .
then 1 + tail big-loop
;

: emit-list ( list -- )
dup c@ ( list elem ) dup 0= if 2drop exit then
( list n ) . char+ tail emit-list
;

: primes
primes-below-16 emit-list
primes-below-256 emit-list
256 big-loop
;

hide any-divide
hide big-loop
hide divisible-by
hide emit-list
hide is-big-prime
hide is-small-prime
hide primes-below-16
hide primes-below-256
hide small-loop
