
( Code own simple interpreter )

: inter

word ( s: name )

dup find dup if ( s: name xt )
( word is in the dictionary, so execute it, and loop... )
swap drop ( s: xt )
execute
br inter
then
drop ( s: name )

number? if ( leave converted number on the stack, and loop... )
br inter
then ( s: name )

( word not defined, so message, skip and loop... )
warn-missing
br inter

;

( enter the interpreter )
inter


: compile-or-execute ( xt -- )
dup test-immediate-flag if
execute exit
then compile,
;

: compiling
word ( s: name )

dup s" ;" s= if drop
['] exit compile, exit
then ( s: name )

dup find dup if ( s: name xt )
swap drop ( s: xt )
compile-or-execute br compiling
then drop ( s: name )

number? if
['] lit compile, , br compiling
then ( s: name )

( word not defined ) warn-missing br compiling
;

( Redefine colon compiler )
: :
word create-entry compiling
;
