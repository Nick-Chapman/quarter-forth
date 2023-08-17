: false     0 ;
: true      65535 ;
: not       true swap if drop false then ;
: >         swap < ;
: square    dup * ;
: min       over over > if swap then drop ;
: expect    over = not if hey . then drop ;

: fact      dup 1 > if dup 1 - fact * then ;
: fib       dup 1 > if dup 1 - fib swap 2 - fib + then ;
