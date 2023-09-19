.." Loading standard ( ... )" cr

: allot     here + here-pointer ! ;

( This is a 16bit Forth; cell size is 2. Chars have size 1 )

: cell    ( -- n )          1 1 + ;     ( cell size )
: cells   ( n -- n )        cell * ;    ( multiply by cell size )
: cell+   ( n -- n )        cell + ;    ( increment by cell size +2 )
: char+   ( n -- n )        1 + ;       ( increment by char size +1 )
: chars   ( n -- n )        ;           ( multiply by char size *1, nop! )

( Output )

: space     bl emit ;
: spaces    dup if space 1 - tail spaces then drop ;

( Defining words )

: variable ( initialized to 0 )
here 0 , constant ;

( Bools )

: false     ( -- b )        0 ;
: true      ( -- b )        0 1 - ;
: or        ( b1 b2 -- b )  if drop true then ;         ( bool disjunction )
: and       ( b1 b2 -- b )  if exit then drop false ;   ( bool conjunction )
: invert    ( b -- b )      true xor ;                  ( bool negation )

( Stack manipulation )

: ?dup  ( x -- 0 | x x )    dup if dup then ;   ( duplicate x if non-zero )
: nip   ( a b -- b )        swap drop ;         ( drop item under stack top. )

: rot   >r swap r> swap ;
: -rot  swap >r swap r> ;

: 2dup  over over ;
: 2drop drop drop ;

( Numbers )

: >         swap < ;
: <=        > invert ;
: >=        < invert ;

: 0<      ( n -- flag )     0 < ;                       ( n is less than zero )
: 0=      ( n -- flag )     0 = ;                       ( n is zero )
: 1+      ( n1 -- n2 )      1 + ;                       ( increment )
: 1-      ( n1 -- n2 )      1 - ;                       ( decrement )

: negate  ( n1 -- n2 )      0 swap - ;                  ( arithmetic negation )
: abs     ( n -- u )        dup 0< if negate then ;     ( absolute value )

: min       over over > if swap then drop ;
: max       over over < if swap then drop ;

: mod ( n n -- n ) /mod drop ;

: /  ( a b -- a ) /mod nip ;

( Misc )

: +! ( n a ) swap over @ + swap ! ;

( Alternative comments, useful since parens don't nest )

: {         key [char] } = if exit then tail { ; immediate

( Tick )

: ' ( "name" -- xt|0 ) word find! ;

( Repeated execution )

: times ( xt n -- ) ( call xt, n times )
dup if >r dup >r ( xt )
execute
r> r> ( xt n )
1 - tail times
then drop drop
;

( Tail recurse to current definition )

: recurse ( "word" -- )
latest
['] lit compile, ,
['] jump compile,
; immediate


1 1 + dup * dup * dup * constant 256

: akey?   key? 256 mod ;
: ekey?   key? 256 / ;


( Loops -- do..i..loop )

: do
['] >r compile,
['] >r compile,
here
; immediate

: i
['] r> compile,
['] r> compile,
['] dup compile,
['] >r compile,
['] swap compile,
['] >r compile,
; immediate

: loop
['] r> compile,
['] r> compile,
['] 1 compile,
['] + compile,
['] 2dup compile,
['] >r compile,
['] >r compile,
['] < compile,
['] 0branch compile,
here - ,
['] r> compile,
['] r> compile,
['] 2drop compile,
; immediate


{ words-since char ) emit cr }
