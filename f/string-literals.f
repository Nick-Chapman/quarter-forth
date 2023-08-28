
( Am using ['] here - but perhaps better to have branch, and lit, )

: [']
word safe-find non-immediate-literal
; immediate


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
