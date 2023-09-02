.." Loading interpreter.f" cr

( define top-level interpreter in forth, and enter it... )

: interpreter ( This is traditionaly & confusingly known as "quit" )

( [char] > emit )
word ( s: name )

dup find dup if ( s: name xt )
( word is in the dictionary, so execute it, and loop... )
swap drop ( s: xt )
execute
tail interpreter
then
drop ( s: name )

number? if ( leave converted number on the stack, and loop... )
tail interpreter
then ( s: name )

( word not defined, so message, skip and loop... )
warn-missing
tail interpreter

;
interpreter ( enter! )


( define colon-compiler in forth; replacing : )

: compile-or-execute ( xt -- )
dup immediate? if
execute exit
then compile,
;

: compiling
word ( s: name )

dup s" ;" s= if drop
( ['] exit compile, ) ( OLD )
ret, ( OPTIMIZED )
exit

then ( s: name )

dup find dup if ( s: name xt )
swap drop ( s: xt )
compile-or-execute tail compiling
then drop ( s: name )

number? if
['] lit compile, , tail compiling
then ( s: name )

( word not defined ) warn-missing tail compiling
;

( Now redefine : )
: :
word create-entry compiling
;
