
: immediate latest immediate^ ;

: cr        13 emit ;
: here      here-pointer @ ;
: allot     here + here-pointer ! ;
: if        0branch, here 0 ,     ; immediate
: then      dup here swap - swap ! ; immediate
: exit      r> drop ;
: bl        32 ;
: space     bl emit ;
: >         swap < ;

: (         key [char] ) = if exit then tail ( ; immediate

( Now we can write comments! Woo hoo! )


( Drop the top item on the return stack )
: r>drop
r> r> drop >r
;

: jump ( xt -- ) ( R: x y -- y )
r>drop
execute
;

( definition cycles, across: word, find, tail, ['] and comments

comments need tail
word need tail
find need tail
['] needs word/find
tail needs word/find/[']
Everything wants comment.
)


( Define "word" in Forth )

: word-loop-2 ( a -- ) ( Keep chars until whitespace )
key dup 33 < if ( a c ) ( whitespace )
drop 0 swap c! exit ( null-terminator )
then over c! ( a ) 1 + tail word-loop-2 ( keep collecting... )
;

: word-loop-1 ( a -- ) ( Skip leading whitespace )
key dup 33 < if ( a c ) ( whitespace )
drop tail word-loop-1 ( keep skipping... )
then over c! ( a ) 1 +
tail word-loop-2 ( collect first char and keep collect... )
;

: word ( "name" -- str )
here 100 + dup word-loop-1 ;


( Define "find" in Forth )

: nip ( a b -- b ) swap drop ;

: find-loop ( s x -- x )
dup if ( s x )
dup hidden? if xt->next tail find-loop then
over over ( s x s x ) xt->name ( s x s s2 ) s= if ( s x ) nip exit
then xt->next tail find-loop
then ( s 0 ) nip
;

: find ( string -- xt )
latest find-loop
;

( Define "[']" in Forth )

: ['] ( comp: "name" ) ( run: -- xt )
word find non-immediate-literal
; immediate


( Define "tail" in Forth )

: tail ( "name" )
word find ( xt )
['] lit compile, ,
['] jump compile,
; immediate


( Strings Literals... )

: collect-string
key dup [char] " = if exit
then c, tail collect-string
;

( Compile code for a literal string, leaving address on stack )

: s" ( ..." -- string )
( make a branch slot )          ['] branchA compile, here 0 , ( TODO: use branchR )
( note where string starts )    here swap
( collect the string chars )    collect-string drop ( the closing " )
( add a null )                  0 c,
( fill in the branch slot )     here swap !
( push string at runtime )      ['] lit compile, ,
; immediate


( Compile code to emit a literal string )

: ." ( ..." )
['] s" execute
['] type compile,
; immediate


( Print literal string while interpreting )

: .."
here
['] ." execute
ret,
dup execute
here-pointer !
;


( tick and hide )

: warn-missing ( string -- )
." ** No such word: " type cr
crash-only-during-startup
;

: checked-find
dup find dup ( str xt xt )
if ( str xt )
nip exit
then ( str 0 )
drop warn-missing
;

: hide
word checked-find hidden^
;

: ' word checked-find ;


.." Loaded  fundamental.f " cr
