.." Loading reference ( " latest

( Forth reference implementations for ops currently Asm coded )


( String equality )

: s= ( a1 a2 -- flag )
over over c@ swap c@ over ( a1 a2 c2 c1 c2 ) = if
0 = if drop drop 0 1 - exit then
1 + swap 1 + tail s=
then drop drop drop 0
;


( String print )

: type ( a -- )
dup c@ ( a c ) dup if ( a c ) emit ( a ) 1 + tail type
then drop drop
;


( Word )

: is-white ( c -- flag ) bl swap < 0 1 - xor ; ( <= 32 )

: skip-leading-whitespace
key dup is-white if ( c )
drop tail skip-leading-whitespace ( keep skipping... )
then c, ( collect first char ) ;

: collect-while-not-whitespace
key dup is-white if ( c )
drop 0 c, exit ( add null-terminator )
then c, tail collect-while-not-whitespace ( colect & keep collecting... ) ;

: word, ( "name" -- ) skip-leading-whitespace collect-while-not-whitespace ;
: word ( "name" -- str ) here word, ;
: transient-word ( "name" -- str ) word dup here-pointer ! ;


( Find )

: find-loop ( s x -- x )
dup if ( s x )
dup hidden? if xt->next tail find-loop then
over over ( s x s x ) xt->name ( s x s s2 ) s= if ( s x ) swap drop exit
then xt->next tail find-loop
then ( s xt ) drop drop 0 ( xt might not be 0 in case word is hidden ) ;

: find ( string -- xt|0 ) latest find-loop ;
: find! ( "name" -- xt|0 )
dup find dup if swap drop exit then
drop type [char] ? emit cr crash-only-during-startup ;


hide collect-while-not-whitespace
hide find-loop
hide is-white
hide skip-leading-whitespace
hide word,
words-since char ) emit cr
