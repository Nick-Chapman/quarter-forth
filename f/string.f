
( Strings Literals... )


: ['] ( comp: "name" ) ( run: -- xt )  ( TODO: must we use this here? )
( word find non-immediate-literal )
tick: non-immediate-literal             ( Nice to use tick: ? )
; immediate


: collect-string
key dup [char] " = if exit
then c, tail collect-string
;

( Compile code for a literal string, leaving address on stack )

: s" ( ..." -- string )
( make a branch slot )          ['] branchA compile, here 0 , ( TODO: use branchR )
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

.." Loaded  string.f" cr
