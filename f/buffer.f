.." Loading buffer" cr

get-key constant old-key
: raw-key  old-key execute ;

79 constant key-buffer-size ( not 80, so blinking cursor remains on line )

here
key-buffer-size 2 + allot ( +2 for the newline & null )
constant key-buffer
0 key-buffer c!

: at-start-of-buffer      ( a -- flag ) key-buffer = ;
: is-space-left-in-buffer ( a -- flag ) key-buffer - key-buffer-size < ;

: is-newline dup 13 = swap 10 = or ;
: is-backspace 8 = ;
: is-printable dup 32 >= swap 127 <= and ;


( Replace the inner echo-{enabled,on,off} )
echo-enabled @ variable echo-enabled echo-enabled ! echo-off
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

over at-start-of-buffer if drop recurse ( ignore backspace )

then dup echo space echo ( Handle the backspace visually )
1 - tail fill-loop ( Move the pointer back one step  )

then dup is-printable 0= if drop recurse ( ignore non-printable )

then over is-space-left-in-buffer 0= if drop recurse ( ignore char )

then ( a c )
echo 1 + ( show char and record in buffer )
recurse
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

' buffered-key set-key ( Install the buffered-key input routine )

( All text which follows must be within the max line length )

hide at-start-of-buffer
hide buffered-key
hide echo
hide fill
hide fill-loop
hide is-backspace
hide is-newline
hide is-printable
hide is-space-left-in-buffer
hide kb-pointer
hide key-buffer
hide key-buffer-size
hide ok
hide old-key
hide raw-key
hide reset-kb-pointer
