
:: immediate latest immediate^ ;

:: here      here-pointer @ ;
:: if        0branch, here 0 ,     ; immediate
:: then      dup here swap - swap ! ; immediate
:: exit      r> drop ;

:: (         key [char] ) = if exit then tail ( ; immediate

( Now we can write comments! Woo hoo! )

( Alternative comments, useful as they dont nest )
:: { key [char] } = if exit then tail { ; immediate


:: 'A'       [char] A ;
:: 'B'       [char] B ;
:: 'C'       [char] C ;
:: '?'       [char] ? ;
:: 0         0 ;

( Need entry/call because of transient string buffer )

:: 0find! ( "name" -- xt|0 )
dup 0find dup if swap drop exit then
drop type '?' emit cr crash-only-during-startup
;

:: tick: 0word 0find! ; ( KILL? )
:: entry: 0word entry, ;
:: call: 0word 0find! compile, ;

( Some strings to compare against )

here char [ , 0 , constant string[
here char ; , 0 , constant string;


( temp access to hide for dev... )

:: x-hide ( xt|0 -- )
dup if hidden^ exit then ( dont try to flip bit on a 0-xt )
;

:: hide ( "name" -- )
0word 0find! x-hide
;


