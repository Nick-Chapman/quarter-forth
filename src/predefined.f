
( Heap )

: here      here-pointer @ ;
: allot     here + here-pointer ! ;
: cell      2 ;
: cells     cell * ;

( Control flow )

: if        0branch, here cell allot ; immediate
: then      here swap !              ; immediate

( Output )

: cr        13 emit ;
: bl        32 ;
: space     bl emit ;
: spaces    dup if space 1 - br spaces then drop ;
: ?         @ . ;

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
