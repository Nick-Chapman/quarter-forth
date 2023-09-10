
( A few important words which we define early )

: ~ char emit ;
~ e ~ a ~ r ~ l ~ y
cr


: ' ( "name" -- xt )
word find!
;


: [compile] ( "name" -- )
' compile,
; immediate


: ['] ( comp: "name" ) ( run: -- xt )
' [compile] literal
; immediate


: constant ( x "name" -- )
word entry,
['] lit compile, ,
['] exit compile,
;


: tail ( "name" )
word find! ['] branch compile, ,
; immediate
