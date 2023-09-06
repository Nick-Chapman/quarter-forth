
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

: compiling
0word ( name ) dup

( s" ;" )               ( IF WE HAD STRINGS )
( lit [ string; , ] )   ( THE SAME AS THE NEXT LINE )
[ string; ] literal

s= if drop ret, ( OPTIMIZED ) exit

then ( name )

dup 0find dup if ( name xt )
swap drop ( xt )
compile-or-execute tail compiling
then drop ( name )

number? if
['] lit compile, , tail compiling
then ( name )

( word not defined )
'C' emit type '?' emit cr
crash-only-during-startup
tail compiling
;

: : 0word entry, compiling ;

: [ interpreter ; immediate
: ] r> drop ;

