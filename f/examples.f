
( Simple user examples )

: square    dup * ;
: fact      dup 1 > if dup 1 - fact * then ;
: fib       dup 1 > if dup 1 - fib swap 2 - fib + then ;

3 square    9 x
6 fact      720 x
10 fib      55 x


: even? dup /2 2 * = ;

: collatz
dup .
dup 1 = if drop exit then
dup even? if /2 br collatz then
3 * 1+ br collatz
;

( try: 27 collatz )


( AHA - Use return stack to make useful version of twice )

: twice ( xt -- )
dup >r execute r> execute
;

3 ' square twice    81 x
