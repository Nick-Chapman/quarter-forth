
( Code own simple interpreter )

: inter
( [char] ~ emit ) ( some simple debug to prove we are in this interpreter )

word

number? if ( leave converted number on stack, and loop... )
br inter
then

dup find dup if ( s: name xt )

( word is in the dictionary, so execute it! )
swap drop
execute
br inter

then
( word not defined, so: message, skip and loop... )
drop
warn-missing
br inter

;

( enter the interpreter )
inter
