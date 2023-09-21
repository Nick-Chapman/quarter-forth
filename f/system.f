
: char ( -- c ) word c@ ;

: ~ char emit ;
~ s ~ y ~ s ~ t ~ e ~ m ~ . ~ f
cr

( A few important words which we define early )

: [char] ( comp: "name" -- ) ( run: -- c )
char [compile] literal ; immediate

: ['] ( comp: "name" ) ( run: -- xt )
' [compile] literal ; immediate

: constant ( x "name" -- )
entry:
['] lit compile, ,
['] exit compile, ;

( We have already defined "if" and "then" in boot.f )
( But we'll define them again here using standard Forth )
( and also "else" )

: ahead> ( -- a ) here 0 , ;
: <patch ( a -- ) dup here swap - swap ! ;

: if     ['] 0branch compile, ahead> ; immediate
: then   <patch                      ; immediate
: else   ['] branchR compile, ahead> swap <patch ; immediate

( Strings Literals... )

: collect-string
key dup [char] " = if exit
then c, tail collect-string
;

( Compile code for a literal string, leaving address on stack )

: s" ( ..." -- string )
( make a branch slot )          ['] branchR compile, ahead>
( note where string starts )    here swap
( collect the string chars )    collect-string drop ( the closing " )
( add a null )                  0 c,
( fill in the branch slot )     <patch
( push string at runtime )      ['] lit compile, ,
; immediate

( Compile code to emit a literal string )

: ." ( ..." )
['] s" execute
['] type compile,
; immediate

( Crash with string message )

: abort" ( ..." )
['] s" execute
['] type compile,
['] cr compile,
['] crash compile,
; immediate

( Print literal string while interpreting )

: .."
here
['] ." execute
ret,
dup execute
here-pointer !
;

: space     bl emit ;
: rot       >r swap r> swap ;
: -rot      swap >r swap r> ;

( "words": Print available words -- oldest first )

: show-if-not-hidden ( xt -- )
dup hidden? if drop exit then xt->name type space
;

: words-continue ( xtEarlier xt -- xtEarlier xt )
over over = if exit then
dup -rot xt->next words-continue rot
dup show-if-not-hidden
drop
;

: words-since ( xtEarlier -- ) latest words-continue drop drop ;
: words 0 words-since cr ;

( hide )

: x-hide ( xt|0 -- )
dup if hidden^ exit then ( dont try to flip bit on a 0-xt )
;

: hide ( "name" -- ) ' x-hide ;

( Standard Forth words )

: allot     here + here-pointer ! ;

( This is a 16bit Forth; cell size is 2. Chars have size 1 )

: cell    ( -- n )          1 1 + ;     ( cell size )
: cells   ( n -- n )        cell * ;    ( multiply by cell size )
: cell+   ( n -- n )        cell + ;    ( increment by cell size +2 )
: char+   ( n -- n )        1 + ;       ( increment by char size +1 )
: chars   ( n -- n )        ;           ( multiply by char size *1, nop! )

( Output )

: space     [ bl ] literal emit ;
: spaces    dup if space 1 - tail spaces then drop ;

( Defining words )

: variable ( initialized to 0 )
here 0 , constant ;

( Bools )

: false     ( -- b )        0 ;
: true      ( -- b )        [ 0 1 - ] literal ;
: or        ( b1 b2 -- b )  if drop true then ;         ( bool disjunction )
: and       ( b1 b2 -- b )  if exit then drop false ;   ( bool conjunction )
: invert    ( b -- b )      true xor ;                  ( bool negation )

( Stack manipulation )

: ?dup  ( x -- 0 | x x )    dup if dup then ;   ( duplicate x if non-zero )
: nip   ( a b -- b )        swap drop ;         ( drop item under stack top. )

: rot   >r swap r> swap ;
: -rot  swap >r swap r> ;

: 2dup  over over ;
: 2drop drop drop ;

( Numbers )

: >         swap < ;
: <=        > invert ;
: >=        < invert ;

: 0<      ( n -- flag )     0 < ;                       ( n is less than zero )
: 0=      ( n -- flag )     0 = ;                       ( n is zero )
: 1+      ( n1 -- n2 )      1 + ;                       ( increment )
: 1-      ( n1 -- n2 )      1 - ;                       ( decrement )

: negate  ( n1 -- n2 )      0 swap - ;                  ( arithmetic negation )
: abs     ( n -- u )        dup 0< if negate then ;     ( absolute value )

: min       over over > if swap then drop ;
: max       over over < if swap then drop ;

: mod ( n n -- n ) /mod drop ;

: /  ( a b -- a ) /mod nip ;

( Misc )

: +! ( n a ) swap over @ + swap ! ;

( Alternative comments, useful since parens don't nest )

: {         key [char] } = if exit then tail { ; immediate

( Tick )

: ' ( "name" -- xt|0 ) word find! ;

( Tail recurse to current definition )

: recurse ( "word" -- )
latest
['] lit compile, ,
['] jump compile,
; immediate

1 1 + dup * dup * dup * constant 256

: akey?   key? 256 mod ;
: ekey?   key? 256 / ;

( Not a fully compliant definition for postpone, but it works for do..i..loop )

: postpone ( "word" -- )
'
['] lit compile,
,
['] compile, compile,
; immediate

( Loops -- do..i..loop )

: do
postpone >r
postpone >r
here
; immediate

: i
postpone r>
postpone r>
postpone dup
postpone >r
postpone swap
postpone >r
; immediate

: loop
postpone r>
postpone r>
postpone 1
postpone +
postpone 2dup
postpone >r
postpone >r
postpone <
postpone 0branch
here - ,
postpone r>
postpone r>
postpone 2drop
; immediate

: erase ( a n -- )
dup 0= if 2drop exit then over 0 swap c! swap 1+ swap 1- recurse ;

( Support for numbers... )

( Make the numbers we need )

1 1 +
constant 2

2 1 + dup * 1 +
constant 10

2 dup * dup *
constant 16

16 dup *
constant 256

( Behaviour of . and number? is modal  )

variable hex-mode

: hex       true  hex-mode ! ;
: decimal   false hex-mode ! ;

( Parse an unsigned hex or decimal number )

: decimal-digit? ( c -- flag ) dup [char] 0 >= swap [char] 9 <= and ;

: extended-digit? ( c -- flag ) dup [char] a >= swap [char] f <= and ;

: hex-digit? ( c -- flag )
dup decimal-digit? swap extended-digit? or ;

: digit? ( c -- flag )
hex-mode @ if hex-digit? else decimal-digit? then ;

: convert-digit
dup extended-digit?
if [char] a - 10 +
else [char] 0 -
then
;

: base ( -- n )
hex-mode @ if 16 else 10 then ;

: number-loop ( acc str -- u 1 | 0 )
dup c@ dup 0 = if 2drop ( acc ) 1 exit
then ( acc str c ) dup digit? ( acc str c flag )
dup 0 = if 2drop 2drop 0 exit
then drop convert-digit rot base * + swap char+ ( acc' str' )
tail number-loop
;

: number? ( str -- u 1 | 0 )
dup 0 swap number-loop ( s u 1 | s 0 )
dup if rot drop
then
;

( Print as unsigned decimal )

: print-digit ( 0-9 -- )
[char] 0 + emit
;

: dot-loop ( u -- )
dup 0= if drop exit ( stop; don't print leading zeros ) then
10 /mod ( u%10 u/10 -- ) dot-loop print-digit
;

: .decimal ( n -- ) ( output a value in decimal )
dup 0= if print-digit exit then ( special case for single "0" )
dot-loop
;

: .hex1 ( nibble -- ) ( output nibble as a length-1 hex string )
dup 10 < if print-digit exit then 10 - [char] a + emit ;

: .hex2 ( byte -- ) ( output byte as a length-2 hex string )
16 /mod .hex1 .hex1 ;

: .hex4 ( n -- ) ( output 16-bit cell-value as a length-4 hex string )
256 /mod .hex2 .hex2 ;

: .hex ( n -- ) ( output a value in hex )
.hex4 ;

: . ( u -- ) ( output value in hex/decimal, with trailing space )
hex-mode @ if .hex else .decimal then space ;

: ? ( addr -- ) @ . ;


( Forth reference implementations for s=, type, word and find )

{

  ( String equality )

  : s= ( a1 a2 -- flag )
  over over c@ swap c@ over ( a1 a2 c2 c1 c2 ) = if
  0 = if drop drop 0 1 - exit then
  1 + swap 1 + tail s=
  then drop drop drop 0 ;

  ( String print )

  : type ( a -- )
  dup c@ ( a c ) dup if ( a c ) emit ( a ) 1 + tail type
  then drop drop ;

  ( Word )

  : is-white ( c -- flag ) bl swap < 0 1 - xor ; ( <= 32 )

  : skip-leading-whitespace
  key dup is-white if ( c )
  drop tail skip-leading-whitespace ( keep skipping... )
  then c, ( collect first char ) ;

  : collect-while-not-whitespace
  key dup is-white if ( c )
  drop 0 c, exit ( add null-terminator )
  then c, tail collect-while-not-whitespace ( colect & keep collecting... ) ;

  : word, ( "name" -- str ) here skip-leading-whitespace collect-while-not-whitespace ;
  : word ( "name" -- str ) word, dup here-pointer ! ;

  ( Find )

  : find-loop ( s x -- x )
  dup if ( s x )
  dup hidden? if xt->next tail find-loop then
  over over ( s x s x ) xt->name ( s x s s2 ) s= if ( s x ) swap drop exit
  then xt->next tail find-loop
  then ( s xt ) drop drop 0 ( xt might not be 0 in case word is hidden ) ;

  : find ( string -- xt|0 ) latest find-loop ;
  : find! ( "name" -- xt|0 )
  dup find dup if swap drop exit then
  drop type [char] ? emit cr crash-only-during-startup ;

  hide collect-while-not-whitespace
  hide find-loop
  hide is-white
  hide skip-leading-whitespace

}

( Colon compier: ":" )

: compiling
word
dup s" ;" s= if drop ret, exit then
dup find dup if swap drop dup immediate? if execute else compile, then tail compiling
then drop number? if ['] lit compile, , tail compiling
then ." ** Colon compiler: '" type ." ' ?" cr crash-only-during-startup tail compiling
;

: : entry: compiling ; ( TODO: use word, and entry, in preference to entry: )

( Interpreter: "[" )

: [
word
dup s" ]" s= if drop exit then
dup find dup if swap drop execute tail [
then drop number? if tail [
then ." ** Interpreter: '" type ." ' ?" cr crash-only-during-startup tail [
; immediate

( And enter! ) [

hide -rot
hide .hex1
hide 10
hide 16
hide 2
hide 256
hide 256
hide <patch
hide ahead>
hide base
hide collect-string
hide compile-or-execute
hide compiling
hide compiling
hide convert-digit
hide decimal-digit?
hide digit?
hide dot-loop
hide extended-digit?
hide hex-digit?
hide hex-mode
hide number-loop
hide print-digit
hide rot
hide show-if-not-hidden
hide space
hide word,
hide words-continue
hide x-hide
hide {{
hide ~
