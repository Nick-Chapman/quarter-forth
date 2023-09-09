.." Loading interpeter ( " latest

: [
( debugging... ) ( [char] > emit )
word ( string )

( Is the word the special "]" marker? )
dup s" ]" s= if ( string )

( YES, exit the interpreter loop. )
drop exit then

( Is the word in the dictionary? )
dup find dup if ( string xt )

( YES, execute it, and loop... )
swap drop ( xt ) execute tail [

( NO, name is not in the dictionary... )
then drop ( string )

( Maybe it's a number... )
number? if ( converted-number )

( YES; leave the converted number on the stack, and loop... )
tail [

( NO, word is undefined, so message, skip and loop... )

then ." ** Interpreter: '" type ." ' ?" cr
crash-only-during-startup tail [

; immediate

( enter the interpreter ) [

words-since char ) emit cr
