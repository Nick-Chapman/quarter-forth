.." Loading word.f" cr

( Define "word" in Forth )

: word-loop-2 ( a -- ) ( Keep chars until whitespace )
key dup 33 < if ( a c ) ( whitespace )
drop 0 swap c! exit ( null-terminator )
then over c! ( a ) 1 + tail word-loop-2 ( keep collecting... )
;

: word-loop-1 ( a -- ) ( Skip leading whitespace )
key dup 33 < if ( a c ) ( whitespace )
drop tail word-loop-1 ( keep skipping... )
then over c! ( a ) 1 +
tail word-loop-2 ( collect first char and keep collect... )
;

: word ( "name" -- str )
here 100 + dup word-loop-1 ; ( TODO : why 100+ )
