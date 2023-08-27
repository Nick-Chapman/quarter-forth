
( Heap )

: allot     here + here-pointer ! ;
: cell      2 ;
: cells     cell * ;

( Output )

: bl        32 ;
: space     bl emit ;
: spaces    dup if space 1 - br spaces then drop ;
: ?         @ . ;

: .hh ( a -- )
dup c@ .h 1 + c@ .h ;

( Definitions )

: variable  here cell allot constant ;

( Bools )

: false     0 ;
: true      65535 ;
: invert    true swap if drop false then ;

: >         swap < ;

( Numbers )

: min       over over > if swap then drop ;
: max       over over < if swap then drop ;

( Misc )

: +!        swap over @ + swap ! ;

: welcome
s" Welcome to Nick's Forth-like thing."
type cr ;

( Stack manipulation )

( Drop the first item below the top of stack. )
: nip ( a b -- b )
swap drop ;

: checked-find ( replaces safe-find in kernel )
dup find dup ( str xt xt )
if ( str xt )
nip exit
then ( str 0 )
drop warn-missing
;

( Tick )
: ' word safe-find ;
