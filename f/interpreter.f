
here char ] , 0 , constant string]

: [

( debugging... )
( [char] > emit )

0word ( string )

( Is the word the special "]" marker? )
dup string] s= if ( string )

( YES, exit the interpreter looop )
drop exit then

( Is the name in the dictionary? )
dup 0find dup if ( string xt )

( YES, execute it, and loop... )
swap drop ( xt ) execute tail [

( NO, name is not in the dictionary )
then drop ( string )

( Maybe it's a number... )
number? if ( converted-number )

( YES; leave the converted number on the stack, and loop... )
tail [

( NO; name undefined, so message, skip and loop... )

then [char] >                   ( make it clear where the error is coming from )
emit type [char] ? emit cr      ( standard ? error )
crash-only-during-startup tail [

; immediate

( enter the interpreter ) [
