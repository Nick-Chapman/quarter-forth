
:: immediate latest immediate^ ;
:: here      here-pointer @ ;
:: if        0branch, here 0 ,     ; immediate
:: then      dup here swap - swap ! ; immediate
:: cr        13 emit ;
:: '?'       [char] ? ;
:: '0'       [char] 0 ;
:: '1'       [char] 1 ;
:: 0         0 ;


:: 1interpreter
0word dup 0find dup if
swap drop execute tail 1interpreter
then drop '0' emit type '?' emit cr crash-only-during-startup tail 1interpreter
;

'1' emit cr
1interpreter

:: exit      r> drop ;

:: (         key [char] ) = if exit then tail ( ; immediate

:: 0find-or-crash ( "name" -- xt|0 )
dup 0find dup if swap drop exit then
drop type '?' emit cr crash-only-during-startup
;


( Now we can write comments! Woo hoo! )

( Alternative comments, useful as they dont nest )
:: {         key [char] } = if exit then tail { ; immediate

( Define "[']" in Forth )



( Need entry/call because of transient string buffer )

:: entry: 0word entry, ;

:: tick: 0word 0find-or-crash ;

:: call: tick: compile, ;



( Some strings to compare against )

here char [ , 0 , constant string[
here char ; , 0 , constant string;
