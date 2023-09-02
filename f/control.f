.." Loading control.f ( " latest

( Duplicate the top item on the return stack )
: r-dup
r> dup >r >r
;

( r-dup is also known as twice; lets also define thrice )
: twice: r> dup >r >r ;
: thrice: r> dup dup >r >r >r ;

( Parameter stack shown bottom->top, as normal )
( Return stack shown top->bottom, which makes sense to me! )

(
"fix:" : Fixpoint some code to run forever.
"u" is "user" code to be run; it follows "fix" upto ";".
"m" is "my" code, the code which implements the fix-point.
)
: fix: ( R: u stuff-we-never-reach... )
r-dup ( R: m u )

( Here starts the code labeled as "m" )
( At the point the return stack will be: ) ( R: m u )

r> r> ( m u )
over over ( m u m u )
>r >r ( m u ) ( R: m u )
swap ( u m ) ( R: m u )
>r >r ( R: u m m u )

(
After we exit, we first run the user code. And then run "m" again.
This consumes the top two return stack items, restoring the
return stack to: m u, as required for when "m" is re-entered.
)
;


words-since char ) emit cr
