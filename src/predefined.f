
: false     0 ;
: true      65535 ;
: invert    true swap if drop false then ;

: >         swap < ;
: <>        = invert ;

: square    dup * ;
: fact      dup 1 > if dup 1 - fact * then ;
: fib       dup 1 > if dup 1 - fib swap 2 - fib + then ;

: min       over over > if swap then drop ;
: max       over over < if swap then drop ;

: cr        13 emit ;
: space     32 emit ;
: spaces    dup if space 1 - br spaces then drop ;

: variable  here 0 , constant ;
