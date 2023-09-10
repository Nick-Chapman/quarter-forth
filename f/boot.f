
entry: here
call: here-pointer
call: @
ret,

here
char b c,
char o c,
char o c,
char t c,
0 ,
constant: boot-string

boot-string type cr

char ? constant: '?'
char ) constant: ')'
char : constant: ':'


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

entry: (        immediate
call: key
call: ')'
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

here char } c, char } c, 0 , constant: "}}"

entry: {{
call: word
call: dup
call: "}}"
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
call: boot-string
call: type
call: ':'
call: emit
call: type
call: '?'
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

here char ; , 0 , constant: ";"

entry: compiling
{{ word dup ";" s= }} if
{{ drop ret, exit }} then
{{ dup find dup }} if
{{ swap drop compile-or-execute compiling exit }} then
{{ drop boot-string type ':' emit type '?' emit cr crash compiling exit }}
ret,

( This is our first definition of a colon-compiler )
( It compiles words until ";" marker is reached. )
( It supports immediate words, but still no numeric literals. )

entry: :
{{ word entry, compiling ret, }}
ret,
