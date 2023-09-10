
( A few important words which we define early )

: char ( -- c )
word c@ ;

: ~ char emit ;
~ e ~ a ~ r ~ l ~ y
cr

: ' ( "name" -- xt )
word find! ;

: [compile] ( "name" -- )
' compile, ; immediate

: [char] ( comp: "name" -- ) ( run: -- c )
char [compile] literal ; immediate

: ['] ( comp: "name" ) ( run: -- xt )
' [compile] literal ; immediate

: tail ( "name" )
word find! ['] branch compile, , ; immediate

: constant ( x "name" -- )
word entry,
['] lit compile, ,
['] exit compile, ;
