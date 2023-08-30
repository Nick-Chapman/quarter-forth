
: cr        13 emit ;
: here      here-pointer @ ;
: allot     here + here-pointer ! ;
: if        0branch, here 0 ,   ; immediate
: then      here swap !         ; immediate

: (         key [char] ) = if exit then br ( ; immediate

( Now we can write comments! Woo hoo! )


: ['] ( comp: "word" ) ( run: -- xt )
word safe-find non-immediate-literal
; immediate


( Strings Literals... )

: collect-string
key dup [char] " = if exit
then c, br collect-string
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


( Print literal string while interpreting )

: .."
here
['] ." execute
ret,
dup execute
here-pointer !
;


 .." Loaded  syntax.f " cr
