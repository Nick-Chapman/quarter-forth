.." Loading colon" cr

: compiling
word
dup s" ;" s= if drop ret, exit then
dup find dup if swap drop dup immediate? if execute else compile, then tail compiling
then drop number? if ['] lit compile, , tail compiling
then ." ** Colon compiler: '" type ." ' ?" cr crash-only-during-startup tail compiling
;

: : word entry, compiling ;
hide compiling
