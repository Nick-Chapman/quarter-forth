
: [']
word safe-find non-immediate-literal
; immediate

: here      here-pointer @ ;

: if        ['] 0branch compile, here 0 ,   ; immediate
: then      here swap !                     ; immediate

: (
key [char] ) = if exit
then br (
; immediate

(
Now we have 'paren' comments!
Above we define here/if/then, and use to define comment handling.
This file contains stuff we need to code the interpreter in forth.
)

( Strings )

: collect-string
key dup [char] " = if exit
then c, br collect-string
;

: s"
( make a branch slot )          ['] branch compile, here 0 ,
( note where string starts )    here swap
( collect the string chars )    collect-string drop ( the closing " )
( add a null )                  0 c,
( fill in the branch slot )     here swap !
( push string at runtime )      ['] lit compile, ,
; immediate



: cr   13 emit ;

: warn-missing ( string -- )
s" ** No such word: " type type cr
crash-only-during-startup
;
