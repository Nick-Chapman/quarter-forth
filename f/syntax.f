
: cr        13 emit ;
: here      here-pointer @ ;
: allot     here + here-pointer ! ;
: if        0branch, here 0 ,     ; immediate
: then      dup here swap - swap ! ; immediate
: exit      r> drop ;

: (         key [char] ) = if exit then asm-tail ( ; immediate

( Now we can write comments! Woo hoo! )

( definition cycles...

['] needs find
find need tail
tail needs find and [']
comments need tail
Everything wants comment.

So we choose order:
- asm-tail and asm-find
- then comments
- then [']
- then tail
- then find
)

: ['] ( comp: "word" ) ( run: -- xt )
word find non-immediate-literal
; immediate


( Tail calling -- no need for special asm magic! )

( Drop the top item on the return stack )
: r>drop
r> r> drop >r
;

: jump ( xt -- ) ( R: x y -- y )
r>drop
execute
;

: tail ( "word" )
word find ( xt )
['] lit compile, ,
['] jump compile,
; immediate


( Redefine find in Forth )

: nip ( a b -- b ) swap drop ;

: find-loop ( s x -- x )
dup if ( s x )
over over ( s x s x ) xt->name ( s x s s2 ) s= if ( s x ) nip exit
then xt->next tail find-loop
then ( s 0 ) nip
;

: find ( string -- xt )
latest-entry find-loop
;


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


.." Loaded  syntax.f " cr
