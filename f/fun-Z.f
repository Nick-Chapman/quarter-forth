
( Drop the top item on the return stack )
: r>drop
r> r> drop >r
;

: jump ( xt -- ) ( R: x y -- y )
r>drop
execute
;

( Define "tail" in Forth )

: NO-tail ( "name" )  ( TODO: problem withthis definition of tail - debug! )
word find ( xt )
['] lit compile, ,
['] jump compile,
; immediate

: ' ( "name" -- xt|0 )
word find-or-crash ;


( ---------------------------------------------------------------------- )
( COPY OF fun-A )

: immediate latest immediate^ ;

: qm        [char] ? ;
: cr        13 emit ;
: here      here-pointer @ ;
: allot     here + here-pointer ! ;
: if        0branch, here 0 ,     ; immediate
: then      dup here swap - swap ! ; immediate
: exit      r> drop ;
: bl        32 ;
: space     bl emit ;
: >         swap < ;
: nip       swap drop ;

: (         key [char] ) = if exit then tail ( ; immediate

( Now we can write comments! Woo hoo! )

( Alternative comments, useful as they dont nest )
: {         key [char] } = if exit then tail { ; immediate

( Define "[']" in Forth )

: ['] ( comp: "name" ) ( run: -- xt )
0word 0find non-immediate-literal
; immediate

( Some strings to compare against )

here char [ , 0 , constant string[
here char ; , 0 , constant string;

: find-or-crash ( "name" -- xt|0 )
dup 0find dup if nip exit then
drop type qm emit cr crash-only-during-startup
;

: x-hide ( xt|0 -- )
dup if hidden^ exit then ( dont try to flip bit on a 0-xt )
;

: hide ( "name" -- )
0word find-or-crash x-hide
;

( Need entry/call because of transient string buffer )

: entry: 0word entry, ;
: call: 0word find-or-crash compile, ;



( TODO: code "literal" in Forth, and then backport to Asm )


: literal ( -- x ) ( C: x -- )
lit
[ tick: lit , ]
compile,
,
; immediate
