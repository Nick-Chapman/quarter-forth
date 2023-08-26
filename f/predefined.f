
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
