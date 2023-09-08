.." Loading colon ( " latest

( Define reference implementation of ] and : )

: compile-or-execute ( xt -- )
dup immediate? if
execute exit
then compile,
;

: ['] ( comp: "name" ) ( run: -- xt )  ( TODO: must we use this here? )
( word find non-immediate-literal )
tick: non-immediate-literal             ( Nice to use tick: ? )
; immediate


( We make use of the previous  "]" whilst defining ths one )

here char ; , 0 , constant string;

: compiling
word ( name ) dup

( s" ;" )               ( IF WE HAD STRINGS )
( lit [ string; , ] )   ( THE SAME AS THE NEXT LINE )
[ string; ] literal

s= if drop ret, ( OPTIMIZED ) exit

then ( name )

dup find dup if ( name xt )
swap drop ( xt )
compile-or-execute tail compiling
then drop ( name )

number? if
['] lit compile, , tail compiling
then ( name )

( word not defined )
." ** Colon compiler: '" type ." ' ?" cr
crash-only-during-startup
tail compiling
;

: : word entry, compiling ;

hide [']
hide compile-or-execute
hide compiling
hide string;
words-since char ) emit cr
