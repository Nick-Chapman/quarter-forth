
: expect    over = invert if expect-failed . cr crash then drop ;

( For debugging, turn on echo... )
( echo-on )

3 square square 81 expect
6 fact 720 expect
10 fib 55 expect

false invert true expect
true invert false expect

3 3 = true expect
3 4 = false expect
3 3 <> false expect
3 4 <> true expect
3 4 < true expect
4 3 < false expect
4 3 > true expect
3 4 > false expect

5 6 min 5 expect
6 5 min 5 expect
5 6 max 6 expect
6 5 max 6 expect

3 4 + 7 expect
4 3 + 7 expect
2 5 - 65533 expect
5 2 - 3 expect
3 4 * 12 expect
4 3 * 12 expect

10
: life literal ;
life life + 20 expect

11
x-create life literal ' exit compile,
life life + 22 expect

12
constant life
life life + 24 expect


10 3 + constant lucky
lucky lucky + 26 expect

variable a
variable b

11 a !
22 b !
a @ 11 expect
b @ 22 expect
33 a !
a @ 33 expect
b @ 22 expect

variable eggs
: e 1 eggs +! ;

e e e e eggs @ 4 expect
e e e eggs @ 7 expect

7 square 49 expect
9 ' square execute 81 expect

: sq br square 1 + ;
7 sq 49 expect

immediate? square false expect
immediate? dup false expect
immediate? if true expect

immediate^ square
immediate? square true expect

immediate^ square
immediate? square false expect
