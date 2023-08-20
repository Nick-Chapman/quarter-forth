
: ff over over > if dup fact . 1 + ff then ;
: count dup . 1 + br count then ;

: foo 42 . ;
: thrice dup dup execute execute execute ;
' foo thrice

: test-exit if 111 exit then 222 ;
0 test-exit 222 expect
1 test-exit 111 expect

create ! ' ' compile, ' compile, compile, ' exit compile,

create *2 ! dup ! + ! exit
create *4 ! *2 ! *2 ! exit

5 *4 20 expect

words
