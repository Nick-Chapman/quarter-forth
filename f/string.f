
( Strings Literals... )

: collect-string
key dup [char] " = if exit
then c, tail collect-string
;

( Compile code for a literal string, leaving address on stack )

: s" ( ..." -- string )
( make a branch slot )          ['] branch compile, here 0 ,
( note where string starts )    here swap
( collect the string chars )    collect-string drop ( the closing " )
( add a null )                  0 c,
( fill in the branch slot )     here swap !
( push string at runtime )      ['] lit compile, ,
; immediate

( Compile code to emit a literal string )

: ." ( ..." )
['] s" execute
['] type compile,
; immediate

( Crash with string message )

: abort" ( ..." )
['] s" execute
['] type compile,
['] cr compile,
['] crash compile,
; immediate

( Print literal string while interpreting )

: .."
here
['] ." execute
ret,
dup execute
here-pointer !
;

.." Loaded  string" cr
