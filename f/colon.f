.." Loading colon ( " latest

: compiling
word ( string )

( Is the word the special ";" marker? )
dup s" ;" s= if ( string )

( YES, exit the compiler loop. )
drop ret, exit then

( Is the word in the dictionary? )
dup find dup if ( string xt )

( YES, test the immediate flag: and either execute or compile )
swap drop ( xt )
dup immediate? if execute else compile,

( And continue compiling )
then tail compiling

( NO, name is not in the dictionary... )
then drop ( string )

( Maybe it's a number... )
number? if ( converted-number )

( YES; compile the number as a literal, and loop... )
['] lit compile, , tail compiling

( NO, word is undefined, so message, skip and loop... )

then ." ** Colon compiler: '" type ." ' ?" cr
crash-only-during-startup tail compiling
;

: : word entry, compiling ;

hide compiling
words-since char ) emit cr
