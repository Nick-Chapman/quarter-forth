.." Loading examples.f ( " latest

: spaces    dup if space 1 - tail spaces then drop ;

( Large letter F. Adapted from "starting Forth", by Leo Brodie )

: star      [char] * emit ;
: stars     dup if star 1 - tail stars then drop ;   ( TODO: 0 do star loop )
: margin    cr 30 spaces ;
: blip      margin star ;
: bar       margin 5 stars ;
: F         bar blip bar blip blip cr ;


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
dup even? if /2 tail collatz then
3 * 1 + tail collatz
;

( try: 27 collatz )


( AHA - Use return stack to make useful version of twice )

: twice ( xt -- )
dup >r execute r> execute
;

3 ' square twice    81 x


hide bar
hide blip
hide even?
hide margin
hide spaces
hide square
hide star
hide stars
hide twice
words-since char ) emit cr
