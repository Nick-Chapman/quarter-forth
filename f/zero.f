
.." Loading zero.f " cr


( hiding from kernel.asm )

hide 0branch
hide 0branch,
hide branchA
hide bye
hide c,
hide crash-only-during-startup
hide echo-off
hide here-pointer
hide hidden^
hide immediate^
hide non-immediate-literal
hide reset
hide safe-find
hide strlen
hide tail

( hiding from fundamental )

hide jump
hide nip
hide r>drop
hide warn-missing

( ----------------------------------------------------------------------
Setup level 0...
---------------------------------------------------------------------- )

( Define a few extra thing... )

: three 3 ;
: two 2 ;
: one 1 ;

: warn-missing ( string -- )
." ** No such word: " type cr
crash
;

( Need entry/call because of transient string buffer )
( This is a pain! )

: entry: word entry, ;
: call: word find compile, ;


( TODO : rename wfx-loop as 0interpreter ? )

: wfx-loop ( word-find-execute-loop )
word dup find dup if
swap drop execute tail wfx-loop
then drop ." wfx-stumped: " type cr crash
;

hide :

(
.." ------------------------------" cr words
.." ------------------------------" cr
)
( .." ENTERING LEVEL ZERO... " cr )
wfx-loop

( TODO : move implementation/entry of level-0 interpreter to asm )


( ----------------------------------------------------------------------
Playing with level 0 interpreter...
---------------------------------------------------------------------- )

( Compiling a colon def using entry: and call: works! )
entry: ex1
call: dup
call: *
ret,

( ----------------------------------------------------------------------
Defining a level 0 colon-compiler
---------------------------------------------------------------------- )

( Define most basic colon-compiler "]" using entry: and call: )
( Does report missing words at least! )
( Compiles words until a "[" marker is reached )

entry: ]
call: word
call: dup
s" ["
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
tail ]
then
call: drop
." level0]-stumped: "
call: type
call: cr
call: crash
ret,

entry: :
call: entry:
call: ]
ret,

( ----------------------------------------------------------------------
Playing with level 0 colon-compiler...
---------------------------------------------------------------------- )

( Now our def looks almost normal... just "exit [" instead of ";" )
( And we can also use embedded interpretation )
( We dont have comments within defs though )

: ex2 [  ] dup * [ ret,

( ----------------------------------------------------------------------
Using level 0 to define a level 1 compiler...
---------------------------------------------------------------------- )

(
1] is not properly tail recursive, but never mind for now
It supports immediateness and numerics.
Compiling words until ";" marker
)

: compile-or-execute
dup immediate? [ if ]
execute exit
[ then ] compile,
[ ret,


: 1]
word dup [ s" ;" ] s= [ if ] drop ret, exit
[ then ]
dup find dup [ if ]
swap drop compile-or-execute 1] exit
[ then ] drop
number? [ if ]
[ ['] lit ] compile, , 1] exit
[ then ] warn-missing 1] exit
[ ret,

: ] 1] [ ret, hide 1] ( replace level 0 ] )

( Now we replace : with a ;-terminated version. woop woop! )
: :
word entry, ]
[ ret,

( ----------------------------------------------------------------------
Defining a level 1 interpreter
---------------------------------------------------------------------- )

( A level 1 interpreter will support numerics )
( Pushing on the stack as expected )


: 1interpreter
word ( string )
dup find dup if ( string xt )
( word is in the dictionary, so execute it, and loop... )
swap drop ( xt ) execute tail 1interpreter
then drop ( string )
( word not in dictionary, maybe it's a number... )
number? if ( converted-number ) tail 1interpreter
( word not defined, so message, skip and loop... )
then warn-missing tail 1interpreter
;

( .." ENTERING LEVEL ONE... " cr )
1interpreter


( ----------------------------------------------------------------------
Playing with level 1
---------------------------------------------------------------------- )

( Now we can write normal looking definitions, with final ; )

: ex3 dup * ;

( And since we have immediates, we also get comments in defs! )
( And we also have numbers, lets use them in the example )
( Example is now square then plus 1. So 3-->10-->101 )

: ex4 dup ( inner comment ) * 1 + ;

( But we should like to have versions of [ and ] which play nice )
( [ is an immediate word which starts a nested interpreter )
( And that already suport switch off with ] -- NO IT DOESN'T )
( We can get out with exit... which we name ] )

( "[" was not a work before, so we dont need to hide it )
hide ]

: [ wfx-loop ; immediate
: ] r> drop ;

: ex5
dup * [ three two - ] literal * ( inner com ) 1 +
;

( Run our example. Expect 101 )
: ex ex5 ; ( pick version to run )
( three ex ex . cr )


( NOW WE CAN LOAD EXAMPLES .. WOO HOO )

hide 1interpreter
hide [
hide call:
hide compile-or-execute
hide entry:
hide ex
hide ex2
hide ex3
hide ex4
hide ex5
hide one
hide three
hide two
hide wfx-loop
