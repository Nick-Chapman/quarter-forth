.." Loading word ( " latest

: is-white ( c -- flag ) 33 < ;

: collect-char ( a c -- a' ) over c! 1 + ;

: skip-leading-whitespace ( a -- a' )
key dup is-white if ( a c )
drop tail skip-leading-whitespace ( keep skipping... )
then collect-char ( collect first char )
;

: collect-while-not-whitespace ( a -- )
key dup is-white if ( a c )
drop 0 swap c! exit ( add null-terminator )
then collect-char tail collect-while-not-whitespace ( keep collecting... )
;

: word ( "name" -- str )
here dup skip-leading-whitespace collect-while-not-whitespace ;

hide collect-char
hide collect-while-not-whitespace
hide is-white
hide skip-leading-whitespace
words-since char ) emit cr
