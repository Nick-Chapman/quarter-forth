
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
