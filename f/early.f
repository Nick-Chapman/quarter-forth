
( A few important words which we define early )

: char ( -- c )
word c@ ;

: ~ char emit ;
~ e ~ a ~ r ~ l ~ y
cr

: [char] ( comp: "name" -- ) ( run: -- c )
char [compile] literal ; immediate

: ['] ( comp: "name" ) ( run: -- xt )
' [compile] literal ; immediate

: constant ( x "name" -- )
word entry,
['] lit compile, ,
['] exit compile, ;

( We have already defined "if" and "then" in boot.f )
( But we'll define them again here using standard Forth )
( and also "else" )

: ahead> ( -- a ) here 0 , ;
: <patch ( a -- ) dup here swap - swap ! ;

: if     0branch, ahead>             ; immediate
: then   <patch                      ; immediate
: else   branchR, ahead> swap <patch ; immediate
