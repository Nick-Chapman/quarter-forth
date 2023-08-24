
( Expect... )

: x         over = invert if expect-failed . cr crash then drop ;

( For debugging, turn on echo... )
( echo-on )

( Words which are not really testable:
: (
)

( Also, can't really test words which print:
. cr emit spaces
)

( Stack manipulation )

1 2 3       3 x 2 x 1 x
1 2 3 drop  2 x 1 x
1 2 3 dup   3 x 3 x 2 x 1 x
1 2 3 swap  2 x 3 x 1 x
1 2 3 over  2 x 3 x 2 x 1 x

( Execution tokens )

: inc 1 + ;
' inc 1 swap execute                    2 x
' inc dup 1 swap execute swap execute   3 x

( Heap allocation )

here            here x
here 42 ,       here cell - x
here 7 allot    here 7 - x
3 cells         6 x

( Control flow )

: swap-if-true      if swap then ;
: swap-if-false     if exit then swap ;

1 2 true  swap-if-true   1 x 2 x
1 2 false swap-if-true   2 x 1 x

1 2 true  swap-if-false  2 x 1 x
1 2 false swap-if-false  1 x 2 x

( Output )

bl          32 x
char *      42 x
char hi     104 x

: hi [char] h [char] i ;
hi 105 x 99 104

( Immediacy )

immediate? here     false x
immediate? dup      false x
immediate? if       true x
immediate? literal  true x

( Compilation )

42 : life literal ;
1 life 2                2 x 42 x 1 x

( variable, fetch and store )

variable a
variable b
11 a !
22 b !
a @     11 x
b @     22 x
33 a !
a @     33 x
b @     22 x

( constants )

1 constant one
2 constant two
one two         2 x 1 x

( Bools )

false invert    true x
true invert     false x

3 3 =           true x
3 4 =           false x
3 4 <           true x
4 3 <           false x
4 3 >           true x
3 4 >           false x

( Numbers )

3 4 + 7 x
4 3 + 7 x
2 5 - 65533 x
5 2 - 3 x
3 4 * 12 x
4 3 * 12 x

5 6 min 5 x
6 5 min 5 x
5 6 max 6 x
6 5 max 6 x

( misc: +! )

variable eggs
: e 1 eggs +! ;

e e e e eggs @ 4 x
e e e eggs @ 7 x

( Basic user functions )

: square    dup * ;
: fact      dup 1 > if dup 1 - fact * then ;
: fib       dup 1 > if dup 1 - fib swap 2 - fib + then ;

3 square    9 x
6 fact      720 x
10 fib      55 x

( br is my tail call primitive -- might reconsider )

: sq br square 1 + ;
7 sq                    49 x
