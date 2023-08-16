hello

11 10 dup * swap dup * swap - .

: hb hello bye ;
: sqr dup * ;
: decrement 1 - ;

hb
7 sqr sqr .
100 decrement .

6 7 < .
7 7 < .

6 7 = .
7 7 = .

bye
