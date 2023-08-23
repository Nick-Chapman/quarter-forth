
( Heap )

: here      here-pointer @ ;
: allot     here + here-pointer ! ;
: cell      2 ;
: cells     cell * ;

( Control flow )

: if        lit x['] 0branch compile, here 0 , ;  immediate
: then      here swap ! ;                         immediate

( Output )

: cr        13 emit ;
: space     32 emit ;
: spaces    dup if space 1 - br spaces then drop ;
: ?         @ . ;

( Definitions )

: constant  x-create lit x['] lit compile, , lit x['] exit compile, ;
: variable  here 0 , constant ;

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
