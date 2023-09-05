
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
call: qm
call: emit
call: cr
call: crash-only-during-startup
tail ]
ret,

entry: :
call: entry:
call: ]
ret,

( ----------------------------------------------------------------------
Using level 0 to define a level 1 compiler...
---------------------------------------------------------------------- )

(
1] is not properly tail recursive, but never mind for now -- TODO: why not?
It supports immediateness and numerics.
Compiling words until ";" marker
)

: compile-or-execute
dup immediate? [ if ]
execute exit
[ then ] compile,
[ ret,

: 1]
0word dup
lit [ string; , ] s= [ if ] drop ret, exit
[ then ]
dup 0find dup [ if ]
swap drop compile-or-execute 1] exit
[ then ] drop
number? [ if ]
[ ['] lit ] compile, , 1] exit
[ then ]
type qm emit cr crash-only-during-startup 1] exit
[ ret,

: ] 1] [ ret,
( hide 1] )

( Now we replace : with a ;-terminated version. woop woop! )
: :
0word entry, ]
[ ret,

( ----------------------------------------------------------------------
Defining a level 1 interpreter
---------------------------------------------------------------------- )

( A level 1 interpreter will support numerics )
( Pushing on the stack as expected )

: 1interpreter
( [char] 1 emit [char] > emit )
0word ( string )
dup 0find dup if ( string xt )
( word is in the dictionary, so execute it, and loop... )
swap drop ( xt ) execute tail 1interpreter
then drop ( string )
( word not in dictionary, maybe it's a number... )
number? if ( converted-number ) tail 1interpreter
( word not defined, so message, skip and loop... )
then [char] 1 emit type [char] ? emit cr crash-only-during-startup tail 1interpreter
;

char 1 emit cr
1interpreter


( But we should like to have versions of [ and ] which play nice )
( [ is an immediate word which starts a nested interpreter )
( And that already suport switch off with ] -- NO IT DOESN'T )
( We can get out with exit... which we name ] )


: [ 1interpreter ; immediate
: ] r> drop ;
