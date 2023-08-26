
( Code own simple interpreter )

: inter
( [char] ~ emit ) ( some simple debug to prove we are in this interpreter )

word

number? if ( leave converted number on stack, and loop... )
( [char] # emit ) ( debug )
br inter
then

dup find dup invert if

( word not defined, so: message, skip and loop... )
( TODO: the bad word is not correctly displayed. transient buffer? )
drop
warn-missing
( [char] * emit ) ( debug )
br inter

then
swap drop
( otherwise word is in the dictionary, so execute it! )
( [char] ! emit ) ( debug )
execute
br inter

;

( enter the interpreter )
inter
