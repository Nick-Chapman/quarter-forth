
entry: immediate
' latest compile,
' immediate^ compile,
ret,

entry: [compile]    immediate
' ' compile,
' compile, compile,
ret,

entry: here
[compile] here-pointer
[compile] @
ret,

entry: literal  immediate
[compile] lit
' lit ,
[compile] compile,
[compile] ,
ret,

here
key b c,
key o c,
key o c,
key t c,
0 ,

entry: ."boot"
literal
[compile] type
ret,

."boot" cr

entry: if       immediate
[compile] 0branch,
[compile] here
[compile] 0
[compile] ,
ret,

entry: then     immediate
[compile] dup
[compile] here
[compile] swap
[compile] -
[compile] swap
[compile] !
ret,

entry: exit
[compile] r>
[compile] drop
ret,


entry: tail    immediate
[compile] '
[compile] lit
' branchA ,
[compile] compile,
[compile] ,
ret,


key )
entry: (        immediate
[compile] key
literal
[compile] =
if
[compile] exit
then
tail (
ret,


( Now we can write comments )


( Next we define a compiler of sorts... )
( To avoid writing by hand the sequence of "[compile]" as we did above. )
( "{{" compiles words until a matching marker "}}" is reached. )
( Note the sense of {{..}} is reversed from the standard [..]. )
( By default we are interpreting, but can nest short busts of compilation )
( It makes use of the control flow words defined above: "if", "then" and "exit" )

key ?
key :
here key } c, key } c, 0 ,

entry: {{
[compile] word
[compile] dup
literal ( "}}" )
[compile] s=
if
[compile] drop
[compile] exit
then
[compile] dup
[compile] find
[compile] dup
if
[compile] swap
[compile] drop
[compile] compile,
tail {{
then
[compile] drop
[compile] ."boot"
literal ( ':' )
[compile] emit
[compile] type
literal ( '?' )
[compile] emit
[compile] cr
[compile] crash-only-during-startup
tail {{
ret,


( Now using {{..}} it is easier/cleaner to write more complicated definitions. )
( And in particular a definition for ":" )

entry: compile-or-execute
{{ dup immediate? }} if
{{ execute exit }} then
{{ compile, }}
ret,


key ?
key :
here key ; , 0 ,

entry: compiling
literal ( ";" )
{{ word swap over s= }} if
{{ drop ret, exit }} then
{{ dup find dup }} if
{{ swap drop compile-or-execute compiling exit }} then
{{ drop ."boot" }} literal ( ':' )
{{ emit type }} literal ( '?' )
{{ emit cr crash compiling exit }}
ret,

( This is our first definition of a colon-compiler )
( It compiles words until ";" marker is reached. )
( It supports immediate words, but still no numeric literals. )

entry: :
{{ word entry, compiling ret, }}
ret,
