
char b emit char o dup emit emit char t emit cr

char A constant 'A'
char B constant 'B'
char ? constant '?'
char ) constant ')'

entry: here
call: here-pointer
call: @
ret,

here char [ , 0 , constant string[
here char ; , 0 , constant string;

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
tail (
ret,


( Now we can write comments! Woo hoo! )


( ----------------------------------------------------------------------
Defining a level 0 colon-compiler
---------------------------------------------------------------------- )

( Define most basic colon-compiler "]" using entry: and call: )
( Does report missing words at least! )
( Compiles words until a "[" marker is reached )


entry: ]]
call: word
call: dup
call: string[
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
tail ]]
then
call: drop
call: 'A'
call: emit
call: type
call: '?'
call: emit
call: cr
call: crash ( -only-during-startup )
tail ]]
ret,

entry: almost: ( "almost" because caller has to compile the final ret, )
call: entry:
call: ]]
ret,


( This compiler supports immediateness, but not numbers.
  It compiles words until ";" marker is reached.
  It can't take advantage of immediateness in it's own definition )

almost: compile-or-execute
dup immediate? [ if ]]
execute exit
[ then ]] compile,
[ ret,

almost: 1compiling
word
dup
string;
s= [ if ]] drop ret, exit
[ then ]]
dup find dup [ if ]]
swap drop compile-or-execute 1compiling exit
[ then ]] drop
'B' emit type '?' emit cr
crash 1compiling exit
[ ret,

almost: start]
1compiling [ ret,


( This is out first definition of a semi-working colon compiler )

almost: :
word entry, start]
[ ret,
