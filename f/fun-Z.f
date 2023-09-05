
( Drop the top item on the return stack )
: r>drop
r> r> drop >r
;

: jump ( xt -- ) ( R: x y -- y )
r>drop
execute
;

( Define "tail" in Forth )

: NO-tail ( "name" )  ( TODO: problem withthis definition of tail - debug! )
word find ( xt )
['] lit compile, ,
['] jump compile,
; immediate

: ' ( "name" -- xt|0 )
word find-or-crash ;
