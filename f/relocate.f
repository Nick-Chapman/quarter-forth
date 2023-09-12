.." Loading relocate ( " latest

: is-call [ 14 16 * 8 + ] literal = ;
: is-ret  [ 12 16 * 3 + ] literal = ;

: @rel->abs
dup @ + 2 +
;

: copy-call ( a -- a+3 )
dup 1 + @rel->abs
( dup ." copying: " xt->name type cr )
compile, 3 +
;

: copy-byte ( a -- a+1 )
dup c@
( dup ." copying byte: " .hex2 cr )
c, 1 +
;

: copy-colon-body ( a -- )
dup c@ is-ret if drop ret, exit
then dup c@ is-call if copy-call tail copy-colon-body
then copy-byte tail copy-colon-body
;

: copy-colon-def ( "src" "copy" -- )
' entry: copy-colon-body
;

hide @rel->abs
hide copy-byte
hide copy-call
hide copy-colon-body
hide is-call
hide is-ret
words-since char ) emit cr
