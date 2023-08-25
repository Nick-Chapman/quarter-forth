
( Code own simple interpreter )

: inter
( [char] ~ emit ) ( some simple debug to prove we are in this interpreter )

word

number? if
br inter ( leave converted number on stack, and loop... )
then

find dup-if-not-zero if ( word is in the dictionary, execute it! )

( TODO: print message when word is not defined -- instead of silently ignoring it )

( [char] ! emit ) ( more debug )
entry->xt execute

then
br inter
;

( enter the interpreter )
inter
