
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

: execute_if_not_zero dup if execute exit then drop ;
create interpret ! ' ! execute_if_not_zero ! interpret

: star 42 emit ;
: cr 13 emit ;
: space 32 emit ;
: spaces dup if space 1 - br spaces then drop ;
: stars dup if star 1 - br stars then drop ;
: margin cr 30 spaces ;
: blip margin star ;
: bar margin 5 stars ;
: F bar blip bar blip blip cr ;
