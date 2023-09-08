
.." Loading own-mult ( " latest

: double  dup + ;

: rshift ( u -- u-half bit )
dup /2 dup double rot = invert
;

( Define muliplication via repeated shift & add )
: acc-mult ( n1 n2 -- acc+n1*n2 ) ( R: acc -- )
dup 0= if ( base case; we are done; acc is our answer )
drop drop r> exit
then rshift if ( n1 hn2 ) ( R: acc )
( shifted bit was 1, so add n1 into acc )
over r> + >r ( n1 hn2 ) ( R: acc' )
( fall through )
then swap double swap ( dn1 hn2 ) ( R: acc' )
tail acc-mult
;

: * ( u1 u2 -- u3 )
0 >r tail acc-mult
;

hide acc-mult
hide rshift
hide double

words-since char ) emit cr
