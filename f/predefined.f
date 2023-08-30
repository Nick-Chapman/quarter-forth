.." Loading predefined.f" cr

( This is a 16bit Forth; cell size is 2. Chars have size 1 )

: cell    ( -- n )          2 ;         ( cell size )
: cells   ( n -- n )        cell * ;    ( multiply by cell size )
: cell+   ( n -- n )        cell + ;    ( increment by cell size +2 )
: char+   ( n -- n )        1 + ;       ( increment by char size +1 )
: chars   ( n -- n )        ;           ( multiply by char size *1, nop! )

( Output )

: bl        32 ;
: space     bl emit ;
: spaces    dup if space 1 - br spaces then drop ;
: ?         @ . ;

( Definitions )

: variable  here cell allot constant ;

( Bools )

: false     ( -- b )        0 ;
: true      ( -- b )        65535 ;
: or        ( b1 b2 -- b )  if drop true then ;         ( bool disjunction )
: and       ( b1 b2 -- b )  if exit then drop false ;   ( bool conjunction )
: invert    ( b -- b )      if false exit then true ;   ( bool negation )

( Comparison )

: >         swap < ;

( Numberic )

: 0<      ( n -- flag )     0 < ;                       ( n is less than zero )
: 0=      ( n -- flag )     0 = ;                       ( n is zero )
: 1+      ( n1 -- n2 )      1 + ;                       ( increment )
: 1-      ( n1 -- n2 )      1 - ;                       ( decrement )

: negate  ( n1 -- n2 )      0 swap - ;                  ( arithmetic negation )
: abs     ( n -- u )        dup 0< if negate then ;     ( absolute value )

: min       over over > if swap then drop ;
: max       over over < if swap then drop ;

( Misc )

: +!        swap over @ + swap ! ;

: depth   ( -- n )          sp sp0 swap - /2 ;          ( depth of param stack )


( Stack manipulation )

: ?dup  ( x -- 0 | x x )    dup if dup then ;   ( duplicate x if non-zero )
: nip   ( a b -- b )        swap drop ;         ( drop item under stack top. )

: rot   >r swap r> swap ;


( Tick )

: checked-find ( replaces safe-find in kernel )
dup find dup ( str xt xt )
if ( str xt )
nip exit
then ( str 0 )
drop warn-missing
;

: ' word checked-find ;

: .hh ( a -- )
dup c@ .h 1 + c@ .h ;
