: spin spin ;
: expect    over = invert if hey . spin then drop ;

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
