
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
word find! ['] branchA compile, , ; immediate

: constant ( x "name" -- )
word entry,
['] lit compile, ,
['] exit compile, ;

( We have already defined "if" and "then" in boot.f )
( But we'll define them again here using standard Forth )
( and also "else: )


: if     0branch, here 0 ,      ; immediate
: then   dup here swap - swap ! ; immediate
: else   branchR, here 0 , swap dup here swap - swap ! ; immediate

( TODO: factorize )
