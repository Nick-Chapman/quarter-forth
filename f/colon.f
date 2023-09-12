.." Loading colon" cr

: compiling
transient-word
dup s" ;" s= if drop ret, exit then
dup find dup if swap drop dup immediate? if execute else compile, then tail compiling
then drop number? if ['] lit compile, , tail compiling
then ." ** Colon compiler: '" type ." ' ?" cr crash-only-during-startup tail compiling
;

: : entry: compiling ; ( TODO: use non-transient version )
hide compiling
