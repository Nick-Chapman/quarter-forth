
: ff over over > if dup fact . 1 + ff then ;
: count dup . 1 + br count then ;

: foo 42 . ;
: thrice dup dup execute execute execute ;
' foo thrice

: test-exit if 111 exit then 222 ;
0 test-exit 222 expect
1 test-exit 111 expect

create dub ' dup compile ' + compile ' exit compile
create quad ' dub compile ' dub compile ' exit compile

5 quad 20 expect
