
entry: here
call: here-pointer
call: @
ret,

here
key b c,
key o c,
key o c,
key t c,
0 ,

entry: ."boot"
literal
call: type
ret,

."boot" cr


entry: immediate
call: latest
call: immediate^
ret,

entry: if       immediate
call: 0branch,
call: here
call: 0
call: ,
ret,

entry: then     immediate
call: dup
call: here
call: swap
call: -
call: swap
call: !
ret,

entry: exit
call: r>
call: drop
ret,

key )
entry: (        immediate
call: key
literal
call: =
if
call: exit
then
tail: (
ret,


( Now we can write comments )


( Next we define a compiler of sorts... )
( To avoid writing by hand the sequence of "call:" as we did above. )
( "{{" compiles words until a matching marker "}}" is reached. )
( Note the sense of {{..}} is reversed from the standard [..]. )
( By default we are interpreting, but can nest short busts of compilation )
( It makes use of the control flow words defined above: "if", "then" and "exit" )

key ?
key :
here key } c, key } c, 0 ,

entry: {{
call: word
call: dup
literal ( "}}" )
call: s=
if
call: drop
call: exit
then
call: dup
call: find
call: dup
if
call: swap
call: drop
call: compile,
tail: {{
then
call: drop
call: ."boot"
literal ( ':' )
call: emit
call: type
literal ( '?' )
call: emit
call: cr
call: crash-only-during-startup
tail: {{
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
