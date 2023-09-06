
( ----------------------------------------------------------------------
Defining a level 0 colon-compiler
---------------------------------------------------------------------- )

( Define most basic colon-compiler "]" using entry: and call: )
( Does report missing words at least! )
( Compiles words until a "[" marker is reached )


entry: ]
call: 0word
call: dup
call: lit string[ ,
call: s=
if
call: drop
call: exit
then
call: dup
call: 0find
call: dup
if
call: swap
call: drop
call: compile,
tail ]
then
call: drop
call: type
call: '?'
call: emit
call: cr
call: crash-only-during-startup
tail ]
ret,

entry: almost: ( "almost" because caller has to compile the final ret, )
call: entry:
call: ]
ret,

( ----------------------------------------------------------------------
Using level 0 to define a level 1 compiler...
---------------------------------------------------------------------- )

(
1compiling is not properly tail recursive, but never mind for now -- TODO: why not?
It supports immediateness and numerics.
Compiling words until ";" marker
)

almost: compile-or-execute
dup immediate? [ if ]
execute exit
[ then ] compile,
[ ret,


( WHY IS THIS SO COMPLICATED ?? HURTS MY BRAIN )
( [ tick: lit ] [ literal ] compile, , 1compiling exit )

( [ tick: lit ] [ literal ] compile, , )


almost: 1compiling

0word
dup
lit [ string; , ]

s= [ if ] drop ret, exit
[ then ]
dup 0find dup [ if ]
swap drop compile-or-execute 1compiling exit
[ then ] drop
number? [ if ]

[ tick: lit ] [ literal ] compile, ,
1compiling exit

[ then ]
type '?' emit cr crash-only-during-startup 1compiling exit
[ ret,


almost: :
0word entry, 1compiling
[ ret,


: ] 1compiling ;
: [ 1interpreter ; immediate
