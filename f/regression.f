: show-load s" Loading regression." type cr ; show-load

( Expect... )

: x
over = if drop exit then
s" Expect failed, got: " type . cr crash ( -only-during-startup )
;

( Stack manipulation )

1 2 3       3 x 2 x 1 x
1 2 3 drop  2 x 1 x
1 2 3 dup   3 x 3 x 2 x 1 x
1 2 3 swap  2 x 3 x 1 x
1 2 3 over  2 x 3 x 2 x 1 x
1 2 3 rot   1 x 3 x 2 x
1 2 3 nip   3 x 1 x

( Execution tokens )

: inc 1 + ;
' inc 1 swap execute                    2 x
' inc dup 1 swap execute swap execute   3 x

( Heap allocation )

here            here x
here 42 ,       here cell - x
here 7 allot    here 7 - x
3 cells         6 x

( Char )

bl          32 x
char *      42 x
char hi     104 x

: hi [char] h [char] i ;
hi 105 x 104 x

( Bools )

false invert    true x
true invert     false x

3 3 =           true x
3 4 =           false x
3 4 <           true x
4 3 <           false x
4 3 >           true x
3 4 >           false x

true true or    true x
true false or   true x
false true or   true x
false false or  false x

true true and    true x
true false and   false x
false true and   false x
false false and  false x

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

0 1 - constant -1 ( helper word for minus one! )

-1 0<       true x
 0 0<       false x
 1 0<       false x
-1 0=       false x
 0 0=       true x
 1 0=       false x
 5 1+       6 x
 5 1-       4 x

 1 negate   -1 x
-1 negate    1 x

 1 abs     1 x
-1 abs     1 x

 1 0 ?dup   0 x 1 x
 1 2 ?dup   2 x 2 x 1 x


( misc: +! )

variable eggs
: e 1 eggs +! ;

e e e e eggs @ 4 x
e e e eggs @ 7 x

variable v
0 2 - v ! ( set v to -2 )
( c@ gets the bytes in little endian )
v c@       254 x
v c@ 1 +   255 x


( Cell and Char size )

5 cell+     7 x
5 char+     6 x
8 chars     8 x


( Parameter stack )

sp sp0 =    true x

depth      0 x
5 depth    1 x      drop
5 6 depth  2 x      drop drop


( Basic user functions -- TODO: move out of regression )

: square    dup * ;
: fact      dup 1 > if dup 1 - fact * then ;
: fib       dup 1 > if dup 1 - fib swap 2 - fib + then ;

3 square    9 x
6 fact      720 x
10 fib      55 x


( Tail recursion. br is my tail call primitive -- might reconsider when I have loops )

: sq br square 1 + ;
7 sq                    49 x


( Variables; fetch and store )

variable a
variable b
11 a !
22 b !
a @     11 x
b @     22 x
33 a !
a @     33 x
b @     22 x

( TODO : test char fetch/store -- c@, c! )


( Constants )

1 constant one
2 constant two
one two         2 x 1 x


( Immediacy )

immediate? here     false x
immediate? dup      false x
immediate? if       true x
immediate? literal  true x

( Compilation )

42 : life literal ;
1 life 2                2 x 42 x 1 x
