.." Loading buffer ( " latest

get-key constant old-key

: raw-key  old-key execute ;

here
200 allot
constant key-buffer
0 key-buffer c!

: is-newline dup 13 = swap 10 = or ;
: is-backspace 8 = ;

( Replace the inner echo-{enabled,on,off} )
echo-enabled @ variable echo-enabled echo-enabled !
: echo-on true echo-enabled ! ;
: echo-off false echo-enabled ! ;
: echo echo-enabled @ if emit exit then drop ;

: ok
echo-enabled @ if ."  ok" cr then ;

: fill-loop ( a -- a' )
raw-key ( a c )
over over swap ( a c c a ) c!

( a c ) dup is-newline if ( a c )
echo 1 + ( show newline and record in buffer )
exit ( stop filling )

then ( a c ) dup is-backspace if ( a c )
dup echo space echo ( Handle the backspace visually )
1 - tail fill-loop ( Move the pointer back one step - TODO: check we dont go too far )

then ( a c )
echo 1 + ( show char and record in buffer )
tail fill-loop
;

: fill
( s" filling..." type cr ) ( PROBLEM )
ok
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

( Install the new buffered-key input routine )
' buffered-key set-key

hide buffered-key
hide echo
hide fill
hide fill-loop
hide is-backspace
hide is-newline
hide kb-pointer
hide key-buffer
hide ok
hide old-key
hide reset-kb-pointer
words-since char ) emit cr
