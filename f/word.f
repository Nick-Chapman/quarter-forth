.." Loading word ( " latest

hide transient-word
hide word

: is-white ( c -- flag ) bl swap < 0 1 - xor ; ( <= 32 )

: skip-leading-whitespace
key dup is-white if ( c )
drop tail skip-leading-whitespace ( keep skipping... )
then c, ( collect first char )
;

: collect-while-not-whitespace
key dup is-white if ( c )
drop 0 c, exit ( add null-terminator )
then c, tail collect-while-not-whitespace ( colect & keep collecting... )
;

: word, ( "name" -- )
skip-leading-whitespace collect-while-not-whitespace
;

: word ( "name" -- str )
here word,
;

: transient-word ( "name" -- str )
word
dup here-pointer !
;

hide collect-while-not-whitespace
hide is-white
hide skip-leading-whitespace
hide word,
words-since char ) emit cr
