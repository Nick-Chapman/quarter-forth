
( Define and enter top-level interpreter,  "[" )

: interpreter
( [char] 1 emit )
0word ( string )
dup 0find dup if ( string xt )
( word is in the dictionary, so execute it, and loop... )
swap drop ( xt ) execute tail interpreter
then drop ( string )
( word not in dictionary, maybe it's a number... )
number? if ( converted-number ) tail interpreter
( word not defined, so message, skip and loop... )
then [char] 1 emit type [char] ? emit cr crash-only-during-startup tail interpreter
;

: [ interpreter ; immediate

char 1 emit cr
interpreter
