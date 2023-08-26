
( Heap )

: allot     here + here-pointer ! ;
: cell      2 ;
: cells     cell * ;

( Output )

: cr        13 emit ;
: bl        32 ;
: space     bl emit ;
: spaces    dup if space 1 - br spaces then drop ;
: ?         @ . ;

: .hh ( a -- )
dup c@ .h 1 + c@ .h ;

( Definitions )

: variable  here cell allot constant ;

( Bools )

: >         swap < ;

( Numbers )

: min       over over > if swap then drop ;
: max       over over < if swap then drop ;

( Misc )

: +!        swap over @ + swap ! ;

( Strings )

: collect-string
key dup [char] " = if exit
then c, br collect-string
;

: s"
( make a branch slot )          ['] branch compile, here 0 ,
( note where string starts )    here swap
( collect the string chars )    collect-string drop ( the closing " )
( add a null )                  0 c,
( fill in the branch slot )     here swap !
( push string at runtime )      ['] lit compile, ,
; immediate

: welcome
s" Welcome to Nick's Forth-like thing."
type cr ;
