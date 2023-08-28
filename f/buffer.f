: show-load s" Loading buffer." type cr ; show-load

get-key constant old-key

here
200 allot
constant key-buffer
0 key-buffer c!

: is-newline
dup 13 = swap 10 = or
;

: fill-loop ( a -- a' )
old-key execute ( a c )
over over swap ( a c c a ) c!
( a c ) is-newline if ( a )
1 + exit
then ( a )
1 + br fill-loop
;

: fill
( s" filling..." type cr ) ( PROBLEM )
key-buffer fill-loop
0 swap c! ( add null so we know when the buffer is exhausted )
( s" filling... done!" type cr ) ( PROBLEM )
;

variable kb-pointer : reset-kb-pointer key-buffer kb-pointer ! ;
reset-kb-pointer

: buffered-key ( -- c )
( [char] * emit )
kb-pointer @ c@
dup if ( c )
1 kb-pointer +!
exit
then drop
reset-kb-pointer fill buffered-key
;

( ' buffered-key set-key )
